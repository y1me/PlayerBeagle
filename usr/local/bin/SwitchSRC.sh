#!/bin/bash

CDMD="CD"
ANGMD="ANALOG"
SP1MD="SPDIF1"
SP2MD="SPDIF2"
MPDMD="MPD"
PHMD="PHONO"
DIRPL="/etc/cdplayer"
PLCF="/etc/cdplayer/cdplayer.conf"

log()
{
    logger -t SwitchSource $1
}

if [ ! -f $PLCF ]; then
    mkdir $DIRPL
    touch $PLCF
    echo $SP1MD > $PLCF 
fi

line=$(cat $PLCF)

case "$line" in
    $PHMD)
        echo $SP1MD > $PLCF 
        log "set source spdif1"
        WriteInfo.sh -s "spdif1"
        PCM1792AMute.sh ON
        pkill DaemonPhono.sh
        line="";;

    $SP1MD)
        echo $SP2MD > $PLCF
        log "set source spdif2"
        WriteInfo.sh -s "spdif2"
        line="";;

    $SP2MD)
        echo $ANGMD > $PLCF
        log "set source analog"
        WriteInfo.sh -s "anlg"
        line="";;

    $ANGMD)
        echo $CDMD > $PLCF
        WriteInfo.sh -s "cd"
        LockCmd.sh ON
        log "lock command input"
        ResetAudio.sh
        log "Hardware reset done"
        sleep 3
        DriveCD.sh -l
        log "load and check cd"
        LockCmd.sh OFF
        log "unlock command input"
        PCM1792AMute.sh OFF
        DaemonDsplCD.sh &
        line="";;

    $CDMD)
        log "set source mpd"
        echo $MPDMD > $PLCF
        WriteInfo.sh -s "mpd"
        pkill DaemonDsplCD.sh &
        line="";;

    $MPDMD)
        echo $PHMD > $PLCF
        log "set source phono"
        WriteInfo.sh -s "phono"
        PCM1792AMute.sh OFF
        DaemonPhono.sh &
        line="";;
    *)
        line="";;
esac
