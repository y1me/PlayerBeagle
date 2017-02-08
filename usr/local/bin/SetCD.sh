#!/bin/bash


log()
{
	logger -t AudioService $1
}

touch /ramtmp/Tracks
touch /ramtmp/Ttracks
echo "0" > /ramtmp/Tracks
echo "0" > /ramtmp/Ttracks
