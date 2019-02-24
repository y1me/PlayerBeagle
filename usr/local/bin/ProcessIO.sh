#!/bin/bash

FCMD="/ramtmp/CommandIHM"
CDMD="/etc/cdplayer/cdplayer"
ANGMD="/etc/cdplayer/analog"
SP1MD="/etc/cdplayer/spdif1"
SP2MD="/etc/cdplayer/spdif2"
MPDMD="/etc/cdplayer/mpd"
PHMD="/etc/cdplayer/phono"
DIRPL="/etc/cdplayer"
CDTRCL="/ramtmp/CDTrayClose"
TOC="/ramtmp/toc"
TTR="/ramtmp/Ttracks"
CTR="/ramtmp/Ctracks"
CDPLAY="/ramtmp/CDisPlaying"
CDPAUSE="/ramtmp/CDisPausing"
CDCTRL="/ramtmp/cdcontrol"
VOLCF="/etc/cdplayer/Volume.conf"
MUTE="/ramtmp/mute"
INFO="/ramtmp/inforunning"
# Log in syslog
log()
{
	logger -t ProcessIO $1
}

# Eject CD
EjectCD()
{
    if [ -f $CDMD ]; then
        DriveCD.sh --eject
        if [ -f $INFO ]; then
            rm $INFO
        fi
    fi
}

# Stop CD
StopCD()
{
	if [ -f $CDMD ]; then
		if [ -f $CDPLAY ]; then
			pkill mplayer
			rm $CDPLAY
		fi
		if [ -f $CDPAUSE ]; then
			rm $CDPAUSE
		fi
		WriteInfo.sh -r stop
	fi

}

# Next Tracks CD
NextTracksCD()
{
	if [ -f $CDMD ]; then
		if [ -f $CDPLAY ]; then
			echo "seek_chapter 1 0" > $CDCTRL
		fi
	fi

}

# Previous Tracks CD
PrevTracksCD()
{
	if [ -f $CDMD ]; then
		if [ -f $CDPLAY ]; then
			echo "seek_chapter -1 0" > $CDCTRL
		fi
	fi

}

# Play/Pause CD
PlayPauseCD()
{
	if [ -f $CDMD ]; then
		if [ ! -f $CDTRCL ]; then
			ejectcd.sh
			#sleep 3
			checkcd.sh
		
			if [ -f $TOC ]; then
				ParseTOC.py -b > $TTR				
				echo "1" > $CTR
			fi
		fi
	fi
	if [ ! -e $CDCTRL ] ; then
		mkfifo $CDCTRL
	fi
	if [ ! -f $CDPLAY ]; then
		if aplay -l | grep "OutPlayer" | grep "card 0" &>/dev/null; then
			mplayer -slave  --cdrom-device=/dev/cdrom --cdda=paranoia=2 cdda://$(cat $CTR)-$(cat $TTR) -ao alsa:device=hw=0.0  -input file=$CDCTRL -idle &>/ramtmp/mplayer.log 2>/ramtmp/mplayer-err.log -cache 1000 &
		else
			mplayer -slave  --cdrom-device=/dev/cdrom --cdda=paranoia=2 cdda://$(cat $CTR)-$(cat $TTR) -ao alsa:device=hw=1.0  -input file=$CDCTRL -idle &>/ramtmp/mplayer.log 2>/ramtmp/mplayer-err.log -cache 1000 &
		fi
		touch $CDPLAY
		WriteInfo.sh -s play
	else
		if [ ! -f $CDPAUSE ]; then
			touch $CDPAUSE
			echo "pause" > $CDCTRL
			WriteInfo.sh -s pause
		else
			rm $CDPAUSE
			echo "pause" > $CDCTRL
			WriteInfo.sh -s play
		fi
			
	fi
		
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
			#StopCD
                        EjectCD
			line="";;
		MENU)
			#PlayPauseCD
			line="";;
		RIGHT)
			#NextTracksCD
			line="";;
		LEFT)
			#PrevTracksCD
			line="";;
		DOWN)
			#StopCD
			line="";;
		RECALL)
			echo "test 2"
			echo $line
			line="";;
		RGBVIDEO)
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
