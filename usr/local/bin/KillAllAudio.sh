#!/bin/bash


log()
{
	logger -t AudioService $1
}

pkill ReadIHM.sh
pkill ProcessIO.sh

AudioDIS.sh
sleep 1
AudioEN.sh

#pkill arecord
#pkill aplay
log "Kill cd player service"
