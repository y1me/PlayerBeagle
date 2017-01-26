#!/bin/bash
if [ ! -d "/ramtmp" ]; then 
	mkdir /ramtmp
fi
mount -t tmpfs -o size=10m tmpfs /ramtmp
stty -F /dev/ttyO4 115200 cs8
touch /ramtmp/CommandIHM
while read -r line < /dev/ttyO4; do
	echo $line >> /ramtmp/CommandIHM
done 
