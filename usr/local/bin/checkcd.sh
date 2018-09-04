#!/bin/bash

log()
{
	logger -t ProcessIO $1
}

STATUS=1;

while [ $STATUS -ne 0 ]; do
sleep 0.5
checkdisc /dev/cdrom
RET=$?
	if [ $RET -eq 10 ]; then
		log  "No disc"
		WriteInfo.sh "nodisc"
		if [ -e /ramtmp/toc ]; then
			rm /ramtmp/toc
		fi
		STATUS=0;
	fi

	if [ $RET -eq 15 ]; then
		log  "No disc info"
	fi

	if [ $RET -eq 20 ]; then
		log  "Tray open"
		WriteInfo.sh "open"
	fi

	if [ $RET -eq 25 ]; then
		log  "Drive not ready"
		WriteInfo.sh "wait"
	fi

	if [ $RET -eq 30 ]; then
		log  "disc ok"
		export HOME=/root/
		cdtoc.exp  > /dev/null 2>&1
		log  "Retrieve TOC disc"
		cdcd tracks  > /ramtmp/toc
		log  "Copy TOC on /ramtmp/toc"
		WriteInfo.sh "discok"
		STATUS=0;
	fi

done
exit 0
