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
			echo "test 3"
			echo $line;;
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
			read -r vol < /etc/Volume.conf
			if  [ $vol -lt 255 ]; then
				vol=$(($vol +2))
				echo $vol > /etc/Volume.conf
				echo $vol
				PCM1792AVolume.sh $vol
				log "Volume send $vol"
				WriteInfo.sh $((($vol-255)/2))"db"
			else
				log "Volume max"
				WriteInfo.sh "0db"
			fi;;
		VOLDW)
			read -r vol < /etc/Volume.conf
			if  [ $vol -gt 0 ]; then
				vol=$(($vol -2))
				echo $vol > /etc/Volume.conf
				echo $vol
				PCM1792AVolume.sh $vol
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
