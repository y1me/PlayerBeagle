#!/bin/bash
CDPLOG="/ramtmp/mplayer.log"
CDCTRL="/ramtmp/cdcontrol"
CDPLAY="/ramtmp/CDisPlaying"

if [ -f $CDPLAY ]; then
    TOTAL=$(ParseTOC.py -b)
    OFFSET=$(ParseTOC.py -d 1 | cut -d" " -f1)
    echo $OFFSET
    #OFFSET=$(echo "$OFFSET/75" | bc)
    #echo $OFFSET
    echo "" > $CDPLOG
    echo "get_time_pos" > $CDCTRL
    sleep 0.08
    CPOS=$(grep -a "POSITION=" $CDPLOG | cut -d"=" -f2)
    CPOS=$(echo "(($CPOS * 75)+0.5)/1" | bc)
    echo $CPOS
    for i in `seq 1 $TOTAL`; do
        STARTCT=$(ParseTOC.py -d $i | cut -d" " -f1)
        STOPCT=$(ParseTOC.py -d $i | cut -d" " -f2)
        echo $STARTCT
        echo $STOPCT
    done
else 
    echo "no cd playing"
fi
