#!/bin/bash
CDMD="/etc/cdplayer/cdplayer"
CDTRCL="/ramtmp/CDTrayClose"
CDPLAY="/ramtmp/CDisPlaying"
CDPAUSE="/ramtmp/CDisPausing"
TOC="/ramtmp/toc"
INFO="/ramtmp/inforunning"
COUNT=0

if [ -f $TOC ] && [ -s $TOC ]; then
    WriteInfo.sh -l "$(ParseTOC.py -a) $(ParseTOC.py -n)"
fi
while true; do
    if [ ! -f $CDPLAY ] || [ ! -f $CDPAUSE ]; then
        if [ ! -f $INFO ] && [ -f $TOC ] && [ -s $TOC ]; then
            WriteInfo.sh -t $(ParseTOC.py -c)
            COUNT=$[$COUNT+1]
            if [ $COUNT -ge 50 ] && [ -s $TOC ]; then
                WriteInfo.sh -l "$(ParseTOC.py -a) $(ParseTOC.py -n)"
                COUNT=1
            fi
        fi
        if [ ! -f $TOC ]; then
            COUNT=$[$COUNT+1]
            if [ $COUNT -ge 50 ]; then
                WriteInfo.sh -r "nodisc"
                COUNT=1
            fi
        fi

    fi
    sleep 0.1
    if [ ! -f $CDMD ]; then
        exit 0
    fi
done
