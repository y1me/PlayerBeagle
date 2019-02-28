#!/bin/bash

VOLCF="/etc/cdplayer/Volume.conf"

log()
{
	logger -t InitDac $1
}

LMK61E2Init.sh > /dev/null 2>&1
log "Set Oscillator"
SRC4392Init.sh > /dev/null 2>&1
log "Set sample converter"
PCM1792AInit.sh > /dev/null 2>&1
log "Set DAC" 
if [ -f $VOLCF ]; then
    read -r vol < $VOLCF
    PCM1792AVolume.sh $vol >> /dev/null
else
    PCM1792AVolume.sh 120 > /dev/null 2>&1
fi
PCM1792AMute.sh OFF > /dev/null 2>&1   
log "Set Volume" 
