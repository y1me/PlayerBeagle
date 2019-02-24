#!/bin/bash

log()
{
	logger -t DaemonPhono $1
}

#KillPhono.sh
#log "Kill phono service"
#sleep 1
SetPhono.sh &
log "Start phono pipe"
sleep 1
while true; do
    sleep 1
    if ! pgrep -x "aplay" > /dev/null
    then
        sleep 5
        SetPhono.sh &
        log "Start phono pipe"
    fi
    sleep 1
    if ! pgrep -x "arecord" > /dev/null
    then
        sleep 5
        SetPhono.sh &
        log "Start phono pipe"
    fi
done
