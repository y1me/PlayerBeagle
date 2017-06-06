#!/bin/bash

FCMD="/ramtmp/CommandIHM"
CDMD="/etc/cdplayer/cdplayer"
CDTRCL="/ramtmp/CDTrayClose"
TOC="/ramtmp/toc"
TTR="/ramtmp/Ttracks"
CTR="/ramtmp/Ctracks"
CDPLAY="/ramtmp/CDisPlaying"
CDPAUSE="/ramtmp/CDisPausing"
CDCTRL="/ramtmp/cdcontrol"
# Log in syslog
log()
{
	logger -t ProcessIO $1
}

# Eject CD
EjectCD()
{
	if [ -f $CDMD ]; then
		ejectcd.sh
		if [ -f $CDTRCL ]; then
			rm $CDPLAY
			rm $CDPAUSE
			sleep 3
			checkcd.sh
		fi
		if [ -f $TOC ]; then
			ParseTOC.py -b > $TTR
			echo "1" > $CTR
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
		WriteInfo.sh stop
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
			sleep 3
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
		WriteInfo.sh play
	else
		if [ ! -f $CDPAUSE ]; then
			touch $CDPAUSE
			echo "pause" > $CDCTRL
			WriteInfo.sh pause
		else
			rm $CDPAUSE
			echo "pause" > $CDCTRL
			WriteInfo.sh play
		fi
			
	fi
		
}

while true; do

	sleep 0.1
	if [ -s $FCMD ]; then
		line=$(head -n 1 $FCMD)
		sed -i 1d $FCMD
	fi
	case "$line" in
		POWER)
			StopCD
			EjectCD
			line="";;
		MENU)
			PlayPauseCD
			line="";;
		RIGHT)
			NextTracksCD
			line="";;
		LEFT)
			PrevTracksCD
			line="";;
		DOWN)
			StopCD
			line="";;
		RESET)
			echo "test 2"
			echo $line
			line="";;
		SOURCE)
			if [ -f /etc/cdplayer/phono ]; then
				rm /etc/cdplayer/phono
				touch /etc/cdplayer/spdif1
				log "set source spdif1"
			elif [ -f /etc/cdplayer/spdif1 ]; then
				rm /etc/cdplayer/spdif1
				touch /etc/cdplayer/spdif2
				log "set source spdif2"
			elif [ -f /etc/cdplayer/spdif2 ]; then
				rm /etc/cdplayer/spdif2
				touch /etc/cdplayer/analog
				log "set source analog"
			elif [ -f /etc/cdplayer/analog ]; then
				rm /etc/cdplayer/analog
				touch $CDMD
				log "set source cdplayer"
				if [ -f $TOC ]; then
					ParseTOC.py -b > $TTR				
				fi
			elif [ -f $CDMD ]; then
				rm $CDMD
				touch /etc/cdplayer/mpd
				log "set source mpd"
			elif [ -f /etc/cdplayer/mpd ]; then
				rm /etc/cdplayer/mpd
				touch /etc/cdplayer/phono


				log "set source phono"
			else
				mkdir /etc/cdplayer
				touch $CDMD
				log "set source cdplayer"
			fi
			SwitchSRC.sh
			line="";;
		MUTE)
			if [ ! -f /ramtmp/mute ]; then
			   	touch /ramtmp/mute 
				log "mute on"
				PCM1792AMute.sh ON
				WriteInfo.sh mute
			else
			   	rm /ramtmp/mute 
				log "mute off"
				PCM1792AMute.sh OFF
				WriteInfo.sh sound
			fi
			line="";;
		VOLUP)
			if [ ! -f /etc/cdplayer/Volume.conf ]; then
				mkdir /etc/cdplayer
				touch /etc/cdplayer/Volume.conf
				echo "195" >> /etc/cdplayer/Volume.conf
			fi
			if [ -f /ramtmp/mute ]; then
			   	rm /ramtmp/mute 
				log "mute off"
				PCM1792AMute.sh OFF
			fi
			read -r vol < /etc/cdplayer/Volume.conf
			if  [ $vol -lt 255 ]; then
				vol=$(($vol +2))
				echo $vol > /etc/cdplayer/Volume.conf
				PCM1792AVolume.sh $vol >> /dev/null
				log "Volume send $vol"
				WriteInfo.sh $((($vol-255)/2))"db"
			else
				log "Volume max"
				WriteInfo.sh "0db"

			fi
			line="";;
		VOLDW)
			if [ ! -f /etc/cdplayer/Volume.conf ]; then
				mkdir /etc/cdplayer
				touch /etc/cdplayer/Volume.conf
				echo "195" >> /etc/cdplayer/Volume.conf
			fi
			if [ -f /ramtmp/mute ]; then
			   	rm /ramtmp/mute 
				log "mute off"
				PCM1792AMute.sh OFF
			fi
			read -r vol < /etc/cdplayer/Volume.conf
			if  [ $vol -gt 0 ]; then
				vol=$(($vol -2))
				echo $vol > /etc/cdplayer/Volume.conf
				PCM1792AVolume.sh $vol >> /dev/null
				log "Volume send $vol"
				WriteInfo.sh $((($vol-255)/2))"db"
			else
				log "Volume min"
				WriteInfo.sh "-128db"
			fi
			line="";;
		*)
	esac


done
