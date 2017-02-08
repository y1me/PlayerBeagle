#!/bin/bash

if trayopen /dev/cdrom; then
	eject -t
else
	eject
	WriteInfo.sh "open"
fi
