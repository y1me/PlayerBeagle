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
			if [ -f $PHMD ]; then
				rm $PHMD
				touch $SP1MD
				log "set source spdif1"
			elif [ -f $SP1MD ]; then
				rm $SP1MD
				touch $SP2MD
				log "set source spdif2"
			elif [ -f $SP2MD ]; then
				rm $SP2MD
				touch $ANGMD
				log "set source analog"
			elif [ -f $ANGMD ]; then
				rm $ANGMD
				touch $CDMD
				log "set source cdplayer"
			elif [ -f $CDMD ]; then
				rm $CDMD
				touch $MPDMD
				log "set source mpd"
			elif [ -f $MPDMD ]; then
				rm $MPDMD
				touch $PHMD
				log "set source phono"
			else
				mkdir $DIRPL
				touch $CDMD
				log "set source cdplayer"
			fi

                        if [ -f $PLCF ]; then
                            mkdir $DIRPL
                            touch $PLCF
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
                            *)
                        esac
if [ -f /etc/cdplayer/phono ]; then
	WriteInfo.sh -s "phono"
        PCM1792AMute.sh OFF
	DaemonPhono.sh &
elif [ -f /etc/cdplayer/spdif1 ]; then
	WriteInfo.sh -s "spdif1
        PCM1792AMute.sh ON
        pkill DaemonPhono.sh
elif [ -f /etc/cdplayer/spdif2 ]; then
	WriteInfo.sh -s "spdif2"
elif [ -f /etc/cdplayer/analog ]; then
	WriteInfo.sh -s "anlg"
elif [ -f /etc/cdplayer/cdplayer ]; then
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
elif [ -f /etc/cdplayer/mpd ]; then
	WriteInfo.sh -s "mpd"
	pkill DaemonDsplCD.sh &
fi
