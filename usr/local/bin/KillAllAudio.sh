#!/bin/bash


log()
{
	logger -t AudioService $1
}

killall ReadIHM.sh
killall ProcessIO.sh
killall arecord
killall aplay
log "Kill cd player service"
