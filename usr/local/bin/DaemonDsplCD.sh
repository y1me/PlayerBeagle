#!/bin/bash
CDMD="/etc/cdplayer/cdplayer"
CDTRCL="/ramtmp/CDTrayClose"
CDPLAY="/ramtmp/CDisPlaying"
CDPAUSE="/ramtmp/CDisPausing"
CDCMD="/ramtmp/CDCommandisPending"
TOC="/ramtmp/toc"
INFO="/ramtmp/inforunning"
INFOTR="/ramtmp/infotransientrunning"
CDTIMEPRINT="printCdTime.sh"
COUNT=0

if [ -f $TOC ] && [ -s $TOC ]; then
    WriteInfo.sh -l "$(ParseTOC.py -a) $(ParseTOC.py -n)"
fi
while true; do
    if [ ! -f $CDCMD ]; then
        if [ ! -f $CDPLAY ]; then
            if pgrep "$CDTIMEPRINT" >/dev/null; then
                echo "kill printCD"
               pkill printCdTime.sh
            fi
            if [ ! -f $INFO ]  && [ ! -f $INFOTR ] && [ -f $TOC ] && [ -s $TOC ]; then
                A=`echo "($(ParseTOC.py -l)/60)*100 + $(ParseTOC.py -l)%60" | bc`

                #WriteInfo.sh -t $(ParseTOC.py -b)$(date -d@$(ParseTOC.py -l) -u +%M%S)
                WriteInfo.sh -t $(ParseTOC.py -b)$A
                COUNT=$[$COUNT+1]
                if [ $COUNT -ge 50 ] && [ -s $TOC ]; then
                    WriteInfo.sh -l "$(ParseTOC.py -a) $(ParseTOC.py -n)"
                    COUNT=1
                fi
            fi
            if [ ! -f $TOC ]; then
                COUNT=$[$COUNT+1]
                if [ $COUNT -ge 50 ]; then
                    WriteInfo.sh -s "nodisc"
                    COUNT=1
                fi
            fi
        else
            if ! pgrep printCdTime.sh >/dev/null; then
                echo "start printCD"
                printCdTime.sh &
            fi
        fi
    fi
    sleep 0.1
    if [ ! -f $CDMD ]; then
        exit 0
    fi
done
