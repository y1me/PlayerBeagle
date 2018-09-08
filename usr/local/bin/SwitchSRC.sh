#!/bin/bash


log()
{
	logger -t AudioService $1
}

if [ -f /etc/cdplayer/phono ]; then
        AudioDIS.sh
        sleep 1
        AudioEN.sh
	DaemonPhono.sh &
	WriteInfo.sh "phono"
elif [ -f /etc/cdplayer/spdif1 ]; then
        pkill DaemonPhono.sh
	WriteInfo.sh "spdif1"
elif [ -f /etc/cdplayer/spdif2 ]; then
	WriteInfo.sh "spdif2"
elif [ -f /etc/cdplayer/analog ]; then
	WriteInfo.sh "anlg"
elif [ -f /etc/cdplayer/cdplayer ]; then
        AudioDIS.sh
        sleep 1
        AudioEN.sh
        sleep 3
	DriveCD.sh -l
	WriteInfo.sh "cd"
elif [ -f /etc/cdplayer/mpd ]; then
	WriteInfo.sh "mpd"
fi
