#!/bin/bash
LOCK="/ramtmp/LockIHM"
CMDIHM="/ramtmp/CommandIHM"

if [ ! -d "/ramtmp" ]; then 
    mkdir /ramtmp
fi

mount -t tmpfs -o size=10m tmpfs /ramtmp
stty -F /dev/ttyO4 115200 cs8
touch $CMDIHM
while read -r line < /dev/ttyO4; do
    if [ ! -f $LOCK ]; then 
        echo $line >> $CMDIHM
    else
        echo $line >> /dev/null
        WriteInfo.sh -r "busy"
    fi
done 
