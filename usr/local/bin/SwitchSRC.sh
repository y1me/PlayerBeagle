#!/bin/bash


log()
{
	logger -t SwitchSource $1
}

if [ -f /etc/cdplayer/phono ]; then
	WriteInfo.sh -s "phono"
        PCM1792AMute.sh OFF
	DaemonPhono.sh &
elif [ -f /etc/cdplayer/spdif1 ]; then
	WriteInfo.sh -s "spdif1"
        PCM1792AMute.sh ON
        pkill DaemonPhono.sh
elif [ -f /etc/cdplayer/spdif2 ]; then
	WriteInfo.sh -s "spdif2"
elif [ -f /etc/cdplayer/analog ]; then
	WriteInfo.sh -s "anlg"
elif [ -f /etc/cdplayer/cdplayer ]; then
	WriteInfo.sh -s "cd"
        LockCmd ON
        log "lock command input"
        ResetAudio.sh
        log "Hardware reset done"
        sleep 3
        DriveCD.sh -l
        log "load and check cd"
        LockCmd OFF
        log "unlock command input"
        PCM1792AMute.sh OFF
elif [ -f /etc/cdplayer/mpd ]; then
	WriteInfo.sh -s "mpd"
fi
