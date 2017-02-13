#!/bin/bash

if  checkdisc /dev/cdrom; then
	WriteInfo.sh "nodisc"
	rm /ramtmp/toc
else
	export HOME=/root/
	cdtoc.exp > /dev/null 2>&1
	cdcd tracks > /ramtmp/toc
	WriteInfo.sh "discok"
fi
