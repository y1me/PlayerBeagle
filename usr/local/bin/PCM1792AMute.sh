#!/bin/bash

MUTE="/ramtmp/mute"

# Log in syslog
log()
{
	logger -t ProcessIO $1
}

if  [ "$1" = "ON" ]; then
	#Set Mute
	i2cset -y 0 0x4f 0x12 0xA1
fi

if  [ "$1" = "OFF" ]; then
	#Unset Mute
	i2cset -y 0 0x4f 0x12 0xA0
fi
