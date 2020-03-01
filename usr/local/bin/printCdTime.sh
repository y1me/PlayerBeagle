#!/bin/bash

FCMD="/ramtmp/CommandIHM"
CDMD="/etc/cdplayer/cdplayer"
CDCMD="/ramtmp/CDCommandisPending"
ANGMD="/etc/cdplayer/analog"
SP1MD="/etc/cdplayer/spdif1"
SP2MD="/etc/cdplayer/spdif2"
MPDMD="/etc/cdplayer/mpd"
PHMD="/etc/cdplayer/phono"
DIRPL="/etc/cdplayer"
CDTRCL="/ramtmp/CDTrayClose"
TOC="/ramtmp/toc"
TTR="/ramtmp/Ttracks"
CTR="/ramtmp/Ctracks"
CDPLAY="/ramtmp/CDisPlaying"
CDPAUSE="/ramtmp/CDisPausing"
CDCTRL="/ramtmp/cdcontrol"
CDDUMP="/cdtmp/"
VOLCF="/etc/cdplayer/Volume.conf"
MUTE="/ramtmp/mute"
INFO="/ramtmp/inforunning"
INFOTR="/ramtmp/infotransientrunning"
# Log in syslog
log()
{
    logger -t ProcessIO $1
}
WAS=$(date +%s%3N)
TRACK=$(cat /cdtmp/CDStatusTracks | cut -d "k" -f 2 | cut -d "." -f 1)
TIME=$(cat /cdtmp/CDStatusTime | cut -d " " -f 2 | cut -d "." -f 1)
MINSEC=$(date -d@$TIME -u +%M:%S)
COUNT=0
#while [ $COUNT -lt 10 ]; do 
while true; do 

    sleep 0.1
    NOW=$(date +%s%3N)
    DELTA=$((NOW-WAS))
    if [ $DELTA -gt 100 ]; then
        WAS=$NOW
        TRACK=$(cat /cdtmp/CDStatusTracks | cut -d "k" -f 2 | cut -d "." -f 1)
        TIME=$(cat /cdtmp/CDStatusTime | cut -d " " -f 2 | cut -d "." -f 1)
        MINSEC=$(date -d@$TIME -u +%M:%S)
        if [ ! -f $INFOTR ] && [ ! -f $CDCMD ]; then
            WriteInfo.sh -t $TRACK$(echo $MINSEC | tr -d :)
        fi
        ((COUNT=COUNT+1))
    fi
done
