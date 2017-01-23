#!/bin/bash

# Log in syslog
log()
{
	logger -t ProcessIO $1
}

while true; do
	line=$(head -n 1 /ramtmp/CommandIHM)
	sed -i 1d /ramtmp/CommandIHM
	case "$line" in
		POWER)
			echo "test 1"
			echo $line;;
		RESET)
			echo "test 2"
			echo $line;;
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
			fi;;
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
			fi;;
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
			fi;;
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
			fi;;
		*)
	esac
sleep 0.3


done
