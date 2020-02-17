#!/bin/bash
LOCK="/ramtmp/LockIHM"
CMDIHM="/ramtmp/CommandIHM"
UART="/dev/ttyS1"

if [ ! -d "/ramtmp" ]; then 
    mkdir /ramtmp
fi

mount -t tmpfs -o size=10m tmpfs /ramtmp
rm /ramtmp/* 
stty -F $UART 115200 cs8 -echo -icanon min 1
touch $CMDIHM
while read -r line < $UART; do
    if [ ! -f $LOCK ]; then 
        echo $line >> $CMDIHM
    else
        echo $line >> /dev/null
        WriteInfo.sh -r "busy"
    fi
done 
