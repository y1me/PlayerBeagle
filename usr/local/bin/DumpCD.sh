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
if [ ! -d "/cdtmp" ]; then 
    mkdir /cdtmp
fi
if ! mountpoint -q $CDDUMP ; then
    mount -t tmpfs -o size=701m tmpfs /cdtmp
fi

cd $CDDUMP
for i in $( eval echo {$1..$(cat $TTR)} )
do
    if [ ! -f "$CDDUMP$i.out" ]; then 
        cdparanoia -S 16 $i-$i -B  
        touch "$CDDUMP$i.out"
    fi
done
if [ $1 -ne 1 ]; then

    for i in $( eval echo {1..$1} )
    do
        if [ ! -f "$CDDUMP$i.out" ]; then 
            cdparanoia -S 12 $i-$i -B  
            touch "$CDDUMP$i.out"
        fi
    done
fi
