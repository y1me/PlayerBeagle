#!/bin/bash


log()
{
	logger -t AudioService $1
}

if [ -f /etc/cdplayer/phono ]; then
        PCM1792AMute.sh OFF
	DaemonPhono.sh &
	WriteInfo.sh "phono"
elif [ -f /etc/cdplayer/spdif1 ]; then
        PCM1792AMute.sh ON
        pkill DaemonPhono.sh
	WriteInfo.sh "spdif1"
elif [ -f /etc/cdplayer/spdif2 ]; then
	WriteInfo.sh "spdif2"
elif [ -f /etc/cdplayer/analog ]; then
	WriteInfo.sh "anlg"
elif [ -f /etc/cdplayer/cdplayer ]; then
       # PCM1792AMute.sh OFF
       # sleep 1
       # AudioEN.sh
       # sleep 3
       #DriveCD.sh -l
	WriteInfo.sh "cd"
elif [ -f /etc/cdplayer/mpd ]; then
	WriteInfo.sh "mpd"
fi
