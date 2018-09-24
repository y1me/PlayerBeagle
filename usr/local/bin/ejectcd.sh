#!/bin/bash

if trayopen /dev/cdrom; then
	eject -t
	WriteInfo.sh -s "close"
	touch /ramtmp/CDTrayClose
else
	eject
	WriteInfo.sh -s "open"
	rm /ramtmp/CDTrayClose
        echo "0" > /ramtmp/Tracks
        echo "0" > /ramtmp/Ttracks
fi
