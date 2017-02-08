#!/bin/bash

if aplay -l | grep "OutPlayer" | grep "card 0" &>/dev/null; then
	#echo "hw:0,0"
	arecord -d hw:1,0 | aplay -d hw:0,0 &  
else
	#echo "hw:1,0"
	arecord -d hw:0,0 | aplay -d hw:1,0 &  
fi
