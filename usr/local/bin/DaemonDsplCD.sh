#!/bin/bash
CDMD="/etc/cdplayer/cdplayer"
CDTRCL="/ramtmp/CDTrayClose"
CDPLAY="/ramtmp/CDisPlaying"
CDPAUSE="/ramtmp/CDisPausing"
TOC="/ramtmp/toc"
INFO="/ramtmp/inforunning"
INFOTR="/ramtmp/infotransientrunning"
COUNT=0

if [ -f $TOC ] && [ -s $TOC ]; then
    WriteInfo.sh -l "$(ParseTOC.py -a) $(ParseTOC.py -n)"
fi
while true; do
    if [ ! -f $CDPLAY ] || [ ! -f $CDPAUSE ]; then
        if [ ! -f $INFO ]  && [ ! -f $INFOTR ] && [ -f $TOC ] && [ -s $TOC ]; then
            #A=`echo "($(ParseTOC.py -l)/60)*100 + $(ParseTOC.py -l)%60" | bc`

            WriteInfo.sh -t $(ParseTOC.py -b)$(date -d@$(ParseTOC.py -l) -u +%M%S)
            #WriteInfo.sh -t $(ParseTOC.py -b)$A
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
