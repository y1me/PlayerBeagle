#!/bin/bash

FCMD="/ramtmp/CommandIHM"
CDMD="/etc/cdplayer/cdplayer"
ANGMD="/etc/cdplayer/analog"
SP1MD="/etc/cdplayer/spdif1"
SP2MD="/etc/cdplayer/spdif2"
MPDMD="/etc/cdplayer/mpd"
PHMD="/etc/cdplayer/phono"
DIRPL="/etc/cdplayer"
CDTRCL="/tmp/CDTrayClose"
TOC="/ramtmp/toc"
TTR="/ramtmp/Ttracks"
CTR="/ramtmp/Ctracks"
CDPLAY="/ramtmp/CDisPlaying"
CDPAUSE="/ramtmp/CDisPausing"
CDCTRL="/tmp/cdcontrol"
VOLCF="/etc/cdplayer/Volume.conf"
MUTE="/ramtmp/mute"
INFO="/ramtmp/inforunning"
# Log in syslog
log()
{
	logger -t ProcessIO $1
}

POWERSet()
{
    if [ -f $PHMD ]; then
        log "power pressed phono"
    elif [ -f $SP1MD ]; then
        log "power pressed spdif1"
    elif [ -f $SP2MD ]; then
        log "power pressed spdif2"
    elif [ -f $ANGMD ]; then
        log "power pressed analog"
    elif [ -f $CDMD ]; then
        # Eject/Load CD
        DriveCD.sh -e &
        log "power pressed cdplayer"
    elif [ -f $MPDMD ]; then
        log "power pressed mpd"
    else
        log "power pressed cdplayer"
    fi
}

DOWNSet()
{
    if [ -f $PHMD ]; then
        log "down pressed phono"
    elif [ -f $SP1MD ]; then
        log "down pressed spdif1"
    elif [ -f $SP2MD ]; then
        log "down pressed spdif2"
    elif [ -f $ANGMD ]; then
        log "down pressed analog"
    elif [ -f $CDMD ]; then
        # Stop CD
        DriveCD.sh -s &
        log "down pressed cdplayer"
    elif [ -f $MPDMD ]; then
        log "down pressed mpd"
    else
        log "down pressed cdplayer"
    fi
}
RIGHTSet()
{
    if [ -f $PHMD ]; then
        log "rigth pressed phono"
    elif [ -f $SP1MD ]; then
        log "rigth pressed spdif1"
    elif [ -f $SP2MD ]; then
        log "rigth pressed spdif2"
    elif [ -f $ANGMD ]; then
        log "rigth pressed analog"
    elif [ -f $CDMD ]; then
        # Next Tracks CD
        DriveCD.sh -n &
        log "rigth pressed cdplayer"
    elif [ -f $MPDMD ]; then
        log "rigth pressed mpd"
    else
        log "rigth pressed cdplayer"
    fi
}

LEFTSet()
{
    if [ -f $PHMD ]; then
        log "left pressed phono"
    elif [ -f $SP1MD ]; then
        log "left pressed spdif1"
    elif [ -f $SP2MD ]; then
        log "left pressed spdif2"
    elif [ -f $ANGMD ]; then
        log "left pressed analog"
    elif [ -f $CDMD ]; then
        # Previous Tracks CD
        DriveCD.sh -r &
        log "left pressed cdplayer"
    elif [ -f $MPDMD ]; then
        log "left pressed mpd"
    else
        log "left pressed cdplayer"
    fi
}

MENUSet()
{
    if [ -f $PHMD ]; then
        log "menu pressed phono"
    elif [ -f $SP1MD ]; then
        log "menu pressed spdif1"
    elif [ -f $SP2MD ]; then
        log "menu pressed spdif2"
    elif [ -f $ANGMD ]; then
        log "menu pressed analog"
    elif [ -f $CDMD ]; then
        log "menu pressed cdplayer"
        # Play/Pause CD
        /root/PlayerBeagle/usr/local/bin/DriveCD.sh -p &
    elif [ -f $MPDMD ]; then
        log "menu pressed mpd"
    else
        log "menu pressed cdplayer"
    fi
}

RGBVIDEOSet()
{
    if [ -f $PHMD ]; then
        rm $PHMD
        touch $SP1MD
        log "set source spdif1"
    elif [ -f $SP1MD ]; then
        rm $SP1MD
        touch $SP2MD
        log "set source spdif2"
    elif [ -f $SP2MD ]; then
        rm $SP2MD
        touch $ANGMD
        log "set source analog"
    elif [ -f $ANGMD ]; then
        rm $ANGMD
        touch $CDMD
        log "set source cdplayer"
    elif [ -f $CDMD ]; then
        rm $CDMD
        touch $MPDMD
        log "set source mpd"
    elif [ -f $MPDMD ]; then
        rm $MPDMD
        touch $PHMD
        log "set source phono"
    else
        mkdir $DIRPL
        touch $CDMD
        log "set source cdplayer"
    fi
    SwitchSRC.sh
}

VOLUPManage()
{
    if [ ! -f $VOLCF ]; then
        mkdir $DIRPL
        touch $VOLCF
        echo "195" >> $VOLCF
    fi
    if [ -f $MUTE ]; then
        rm $MUTE 
        log "mute off"
        PCM1792AMute.sh OFF
    fi
    read -r vol < $VOLCF
    if  [ $vol -lt 255 ]; then
        vol=$(($vol +2))
        echo $vol > $VOLCF
        PCM1792AVolume.sh $vol >> /dev/null
        log "Volume send $vol"
        WriteInfo.sh -r $((($vol-255)/2))"db"
    else
        log "Volume max"
        WriteInfo.sh -r "0db"

    fi
}

VOLDWManage()
{
    if [ ! -f $VOLCF ]; then
        mkdir $DIRPL
        touch $VOLCF
        echo "195" >> $VOLCF
    fi
    if [ -f $MUTE ]; then
        rm $MUTE 
        log "mute off"
        PCM1792AMute.sh OFF
    fi
    read -r vol < $VOLCF
    if  [ $vol -gt 0 ]; then
        vol=$(($vol -2))
        echo $vol > $VOLCF
        PCM1792AVolume.sh $vol >> /dev/null
        log "Volume send $vol"
        WriteInfo.sh -r $((($vol-255)/2))"db"
    else
        log "Volume min"
        WriteInfo.sh -r "-128db"
    fi
}

MUTEManage()
{
    if [ ! -f $MUTE ]; then
        touch $MUTE 
        log "mute on"
        PCM1792AMute.sh ON
        WriteInfo.sh -r "mute"
    else
        rm $MUTE 
        log "mute off"
        PCM1792AMute.sh OFF
        WriteInfo.sh -r "sound"
    fi

}

VolumeInit()
{
    if [ ! -f $VOLCF ]; then
        mkdir $DIRPL
        touch $VOLCF
        echo "195" >> $VOLCF
    fi
    if [ -f $MUTE ]; then
        rm $MUTE 
        log "mute off"
    fi
    PCM1792AMute.sh OFF
    read -r vol < $VOLCF
    PCM1792AVolume.sh $vol >> /dev/null
    log "Volume send $vol"
}

VolumeInit
sleep 2
SwitchSRC.sh
while true; do

	sleep 0.1
	if [ -s $FCMD ]; then
		line=$(head -n 1 $FCMD)
		sed -i 1d $FCMD
	fi
	case "$line" in
		POWER)
                    POWERSet
			line="";;
		MENU)
                    MENUSet
			line="";;
		RIGHT)
                    RIGHTSet
			line="";;
		LEFT)
                    LEFTSet
			line="";;
		DOWN)
                    DOWNSet
			line="";;
		RECALL)
			echo "test 2"
			echo $line
			line="";;
		RGBVIDEO)
                    RGBVIDEOSet
			line="";;
		MUTE)
                    MUTEManage
			line="";;
		VOLUP)
                    VOLUPManage
			line="";;
		VOLDW)
                    VOLDWManage
			line="";;
		ENDINFO)
                    if [ -f $INFO ]; then
                        rm $INFO
                    fi
			line="";;
		*)
	esac


done
