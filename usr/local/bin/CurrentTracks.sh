#!/bin/bash
CDPLOG="/ramtmp/mplayer.log"
CDCTRL="/ramtmp/cdcontrol"

echo "" > $CDPLOG
echo "get_time_pos" > $CDCTRL
sleep 0.08
CPOS=$(grep -a "POSITION=" $CDPLOG | cut -d"=" -f2)
CPOS=$(echo "(($CPOS * 75)+0.5)/1" | bc)
echo $CPOS
