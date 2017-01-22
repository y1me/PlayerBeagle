#!/bin/bash

while true; do
	line=$(head -n 1 /tmp/CommandIHM)
	sed -i 1d /tmp/CommandIHM
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



	sleep 1
done
