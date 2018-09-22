#!/bin/bash
AudioDIS.sh
sleep 1
AudioEN.sh
SetPhono.sh &
sleep 1
while true; do
    sleep 1
    if ! pgrep -x "aplay" > /dev/null
    then
        sleep 5
        SetPhono.sh &
    fi
    sleep 1
    if ! pgrep -x "arecord" > /dev/null
    then
        sleep 5
        SetPhono.sh &
    fi
done
