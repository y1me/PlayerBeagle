#!/bin/bash


log()
{
	logger -t AudioService $1
}


AudioDIS.sh
sleep 1
AudioEN.sh

log "Power reset audio "
