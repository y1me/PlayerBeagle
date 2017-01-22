#!/bin/bash
rm /tmp/CommandIHM
touch /tmp/CommandIHM
while read -r line < /dev/ttyO4; do
	echo $line
	echo $line >> /tmp/CommandIHM
done 




