#!/bin/bash

string=$1

if [ ${#string} == 1 ]; then
	echo "~#B=     "$1"dummydummydummy" > /dev/ttyO4; exit
fi
if [ ${#string} == 2 ]; then 
	echo "~#B=    "$1"dummydummydummy" > /dev/ttyO4; exit
fi
if [ ${#string} == 3 ]; then
	echo "~#B=   "$1"dummydummydummy" > /dev/ttyO4; exit
fi
if [ ${#string} == 4 ]; then
	echo "~#B=  "$1"dummydummydummy" > /dev/ttyO4; exit
fi
if [ ${#string} == 5 ]; then
	echo "~#B= "$1"dummydummydummy" > /dev/ttyO4; exit
fi
	echo "~#B= "$1"dummydummydummy" > /dev/ttyO4; exit
