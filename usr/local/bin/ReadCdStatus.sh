#!/bin/bash
CDCTRL="/tmp/cdcontrol"
CDPLAY="/ramtmp/CDisPlaying"
CDPAUSE="/ramtmp/CDisPausing"
CDSTATTR="/cdtmp/CDStatusTracks"
CDSTATTM="/cdtmp/CDStatusTime"
CDSTATPP="/cdtmp/CDStatusPercent"
MPLOG="/ramtmp/mplayer.log"
TR="/ramtmp/Tracks"
TTR="/ramtmp/Ttracks"
ENDTRACK=$(cat $TTR)
while true; do
    if [ -f $CDPLAY ] && [ ! -f $CDPAUSE ]; then 
        sleep 0.1
        echo "" > $MPLOG
        echo "get_file_name" > $CDCTRL
        sleep 0.1
        echo "file="$(cat $MPLOG | cut -d '=' -f 2) > $CDSTATTR
        echo "" > $MPLOG
        echo "get_time_pos" > $CDCTRL
        sleep 0.1
        echo "time="$(cat $MPLOG | cut -d '=' -f 2) > $CDSTATTM 
        echo "" > $MPLOG
        echo "get_percent_pos" > $CDCTRL
        sleep 0.1
        echo "ppos="$(cat $MPLOG | cut -d '=' -f 2) > $CDSTATPP    
        if cat $CDSTATTR | grep $ENDTRACK > /dev/null 2>&1 && cat $CDSTATPP | grep "100" > /dev/null 2>&1; then
            rm $CDPLAY
            exit 0
        fi
    fi
done 