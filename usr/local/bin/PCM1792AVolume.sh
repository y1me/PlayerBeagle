#!/bin/bash

if  [ "$1" -lt 256 ] && [ "$1" -gt 0 ]; then
	#Setup left volume
	i2cset -y 2 0x4f 0x10 $1
	#Setup Right volume
	i2cset -y 2 0x4f 0x11 $1
	ATT=$( echo "0.5*($1-255)" |bc )
	echo "$ATT dB"
else
	echo "parameter not valid"
fi
