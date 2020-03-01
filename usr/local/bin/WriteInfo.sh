#!/bin/bash

string=$2
INFO="/ramtmp/inforunning"
UART="/dev/ttyS1"

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
        if [ ! -f $INFO ]; then
            touch $INFO
            STRLENGTH=$(echo -n $2 | wc -m)
            echo "sleep $(( $STRLENGTH * 2 )) ; rm $INFO" | at now > /dev/null 2>&1
        fi
        DATA="$(tr [A-Z] [a-z] <<< "$2")"
	echo "~#"$CMD"="   $DATA   "~#" > $UART; exit 0
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
	echo "~#"$CMD"=     "$2"dummydummydummy" > $UART; exit 0
fi
if [ ${#string} == 2 ]; then 
	echo "~#"$CMD"=    "$2"dummydummydummy" > $UART; exit 0
fi
if [ ${#string} == 3 ]; then
	echo "~#"$CMD"=   "$2"dummydummydummy" > $UART; exit 0
fi
if [ ${#string} == 4 ]; then
	echo "~#"$CMD"=  "$2"dummydummydummy" > $UART; exit 0
fi
if [ ${#string} == 5 ]; then
	echo "~#"$CMD"= "$2"dummydummydummy" > $UART; exit 0
fi
if [ ${#string} == 6 ]; then
	echo "~#"$CMD"="$2"dummydummydummy" > $UART; exit 0
fi
exit 1
