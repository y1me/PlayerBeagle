#!/bin/bash

if trayopen /dev/cdrom; then
	eject -t
	sleep 3
	if  checkdisc /dev/cdrom; then
		WriteInfo.sh "nodisc"
	else
		cdtoc.exp > /dev/null 2>&1
		cdcd tracks > /ramtmp/toc
		WriteInfo.sh "discok"
	fi
else
	eject
	rm /ramtmp/toc
fi
