#!/bin/bash

if trayopen /dev/cdrom; then
	eject -t
	touch /ramtmp/CDTrayClose
else
	eject
	WriteInfo.sh "open"
	rm /ramtmp/CDTrayClose
fi
