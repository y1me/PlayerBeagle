#!/bin/bash

log()
{
	logger -t ProcessIO $1
}

status=1;

while [ $status -ne 0 ]; do
sleep 0.5
checkdisc /dev/cdrom

if [ $? -eq 10 ]; then
log  "No disc"
WriteInfo.sh "nodisc"
rm /ramtmp/toc
status=0;
fi

if [ $? -eq 15 ]; then
log  "No disc info"
fi

if [ $? -eq 20 ]; then
log  "Tray open"
WriteInfo.sh "open"
fi

if [ $? -eq 25 ]; then
log  "Drive not ready"
WriteInfo.sh "wait"
fi

if [ $? -eq 30 ]; then
log  "disc ok"
export HOME=/root/
cdtoc.exp > /dev/null 2>&1
cdcd tracks > /ramtmp/toc
WriteInfo.sh "discok"
status=0;
fi

done
