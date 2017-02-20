#!/bin/bash

if aplay -l | grep "OutPlayer" | grep "card 0" &>/dev/null; then
	#echo "hw:0,0"
	arecord -f dat -D hw:1,0 | aplay -D hw:0,0 &  
else
	#echo "hw:1,0"
	arecord -f dat -D hw:0,0 | aplay -D hw:1,0 &  
fi
