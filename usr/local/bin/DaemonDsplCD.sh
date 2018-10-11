#!/bin/bash
CDMD="/etc/cdplayer/cdplayer"
CDTRCL="/ramtmp/CDTrayClose"
CDPLAY="/ramtmp/CDisPlaying"
CDPAUSE="/ramtmp/CDisPausing"
INFO="/ramtmp/inforunning"
COUNT=0

WriteInfo.sh -l "$(ParseTOC.py -a) $(ParseTOC.py -n)"
while true; do
    if [ ! -f $CDPLAY ] || [ ! -f $CDPAUSE ]; then
        if [ ! -f $INFO ] && [ -f $CDTRCL ]; then
            WriteInfo.sh -t $(ParseTOC.py -c)
            COUNT=$[$COUNT+1]
            if [ $COUNT -ge 50 ]; then
                WriteInfo.sh -l "$(ParseTOC.py -a) $(ParseTOC.py -n)"
                COUNT=1
            fi
        fi
    fi
    sleep 0.1
    if [ ! -f $CDMD ]; then
        exit 0
    fi
done
