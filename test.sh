#!/bin/bash

FCMD="/ramtmp/CommandIHM"
CDMD="/etc/cdplayer/cdplayer"
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
# Log in syslog
log()
{
    logger -t ProcessIO $1
}

cd $CDDUMP
for i in $( eval echo {1..$(cat $TTR)} )
do
        if [ ! -f "$CDDUMP$i.out" ]; then 
            if [ ${#i} -eq 1 ]; then
                echo $CDDUMP"track0"$i".cdda.wav"
            else
                echo $CDDUMP"track"$i".cdda.wav"
            fi
        fi
    done
