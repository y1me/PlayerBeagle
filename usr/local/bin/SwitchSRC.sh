#!/bin/bash


log()
{
	logger -t AudioService $1
}

if [ -f /etc/cdplayer/phono ]; then
	arecord -f dat -D hw:1,0 | aplay -D hw:0,0 &
	WriteInfo.sh "phono"
elif [ -f /etc/cdplayer/spdif1 ]; then
	KillPhono.sh
	WriteInfo.sh "spdif1"
elif [ -f /etc/cdplayer/spdif2 ]; then
	KillPhono.sh
	WriteInfo.sh "spdif2"
elif [ -f /etc/cdplayer/analog ]; then
	KillPhono.sh
	WriteInfo.sh "anlg"
elif [ -f /etc/cdplayer/cdplayer ]; then
	KillPhono.sh
	WriteInfo.sh "cd"
elif [ -f /etc/cdplayer/mpd ]; then
	KillPhono.sh
	WriteInfo.sh "mpd"
fi
