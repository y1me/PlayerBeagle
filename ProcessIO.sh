#!/bin/bash

while true; do
	line=$(head -n 1 /ramtmp/CommandIHM)
	sed -i 1d /ramtmp/CommandIHM
	case "$line" in
		POWER)
			echo "test 1"
			echo $line;;
		RESET)
			echo "test 2"
			echo $line;;
		SOURCE)
			echo "test 3"
			echo $line;;
		MUTE)
			echo "test 4"
			echo $line;;
		*)
	esac
sleep 0.3


done
