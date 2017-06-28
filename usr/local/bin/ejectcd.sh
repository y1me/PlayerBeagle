#!/bin/bash

if trayopen /dev/cdrom; then
	eject -t
	WriteInfo.sh "close"
	touch /ramtmp/CDTrayClose
else
	eject
	WriteInfo.sh "open"
	rm /ramtmp/CDTrayClose
fi
