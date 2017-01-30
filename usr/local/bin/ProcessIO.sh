#!/bin/bash

# Log in syslog
log()
{
	logger -t ProcessIO $1
}

while true; do
	sleep 0.1
	if [ -s /ramtmp/CommandIHM ]; then
		line=$(head -n 1 /ramtmp/CommandIHM)
		sed -i 1d /ramtmp/CommandIHM
	fi
	case "$line" in
		POWER)
			if [ -f /etc/cdplayer/cdplayer ]; then
				ejectcd.sh
			fi
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
				touch /etc/cdplayer/cdplayer
				log "set source cdplayer"
			elif [ -f /etc/cdplayer/cdplayer ]; then
				rm /etc/cdplayer/cdplayer
				touch /etc/cdplayer/mpd
				log "set source mpd"
			elif [ -f /etc/cdplayer/mpd ]; then
				rm /etc/cdplayer/mpd
				touch /etc/cdplayer/phono
				log "set source phono"
			else
				mkdir /etc/cdplayer
				touch /etc/cdplayer/cdplayer
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
