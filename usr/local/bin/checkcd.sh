#!/bin/bash
CDOK="/ramtmp/discok"
TOC="/ramtmp/toc"
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
		WriteInfo.sh -r "nodisc"
		if [ -e $TOC ]; then
			rm $TOC
		fi
		STATUS=0;
	fi

	if [ $RET -eq 15 ]; then
		log  "No disc info"
	fi

	if [ $RET -eq 20 ]; then
		log  "Tray open"
		if [ -e $TOC ]; then
			rm $TOC
		fi
		WriteInfo.sh -r "open"
	fi

	if [ $RET -eq 25 ]; then
		log  "Drive not ready"
		WriteInfo.sh -r "wait"
	fi

	if [ $RET -eq 30 ]; then
		if [ ! -e $TOC ]; then
			touch $TOC
		fi
		log  "disc ok"
		export HOME=/root/
		cdtoc.exp  > /dev/null 2>&1
		log  "Retrieve TOC disc"
		cdcd tracks  > $TOC
		log  "Copy TOC on /ramtmp/toc"
                #WriteInfo.sh -l "$(ParseTOC.py -a) $(ParseTOC.py -n)"
		STATUS=0;
	fi

done
exit 0
