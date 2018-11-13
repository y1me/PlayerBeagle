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





VolCtrl.sh --init
sleep 10
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
			SwitchSRC.sh
			line="";;
		MUTE)
                    VolCtrl.sh --mute
			line="";;
		VOLUP)
                    VOLUPManage
                    VolCtrl.sh --up
			line="";;
		VOLDW)
                    VOLDWManage
                    VolCtrl.sh --down
			line="";;
		ENDINFO)
                    if [ -f $INFO ]; then
                        rm $INFO
                    fi
			line="";;
		*)
	esac


done
