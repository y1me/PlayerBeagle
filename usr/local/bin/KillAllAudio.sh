#!/bin/bash


log()
{
	logger -t KillAllAudio $1
}

pkill -9 ReadIHM.sh
pkill -9 ProcessIO.sh

pkill -9 DaemonDsplCD.sh
pkill -9 DaemonPhono.sh

pkill -9 arecord
pkill -9 aplay
log "Kill cd player all service"
