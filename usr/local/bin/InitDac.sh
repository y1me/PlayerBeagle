#!/bin/bash

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
PCM1792AVolume.sh 120 > /dev/null 2>&1
PCM1792AMute.sh OFF > /dev/null 2>&1   
log "Set Volume" 
