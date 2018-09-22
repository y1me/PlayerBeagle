#!/bin/bash

string=$2

case $1 in
    -t|--time)
        CMD='A'
        ;;
    -s|--short)
        CMD='B'
        ;;
    -l|--long)
        CMD='C'
        if [ ${#string} -lt 10 ]; then
            echo "argument too short"
            exit 1
        fi
	echo "~#"$CMD"="$2"~#" > /dev/ttyO4; exit 0
        ;;
    -r|--transient)
        CMD='D'
        ;;
    *)
        echo "Print info on LED display"
        echo "-t, --time        time info 6 digit command"
        echo "-s, --short       info 6 letter command"
        echo "-l, --long        info data min 10 symbols max 64 symbols command"
        echo "-r, --transient   timed info data"
        exit 1
        ;;
esac


if [ ${#string} == 1 ]; then
	echo "~#"$CMD"=     "$2"dummydummydummy" > /dev/ttyO4; exit 0
fi
if [ ${#string} == 2 ]; then 
	echo "~#"$CMD"=    "$2"dummydummydummy" > /dev/ttyO4; exit 0
fi
if [ ${#string} == 3 ]; then
	echo "~#"$CMD"=   "$2"dummydummydummy" > /dev/ttyO4; exit 0
fi
if [ ${#string} == 4 ]; then
	echo "~#"$CMD"=  "$2"dummydummydummy" > /dev/ttyO4; exit 0
fi
if [ ${#string} == 5 ]; then
	echo "~#"$CMD"= "$2"dummydummydummy" > /dev/ttyO4; exit 0
fi
	echo "~#"$CMD"="$2"dummydummydummy" > /dev/ttyO4; exit 0
