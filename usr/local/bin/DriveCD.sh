#!/bin/bash
# from : https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

CDTRCL="/ramtmp/CDTrayClose"
TOC="/ramtmp/toc"
TTR="/ramtmp/Ttracks"
TR="/ramtmp/Tracks"
CTR="/ramtmp/Ctracks"
CDPLAY="/ramtmp/CDisPlaying"
CDPAUSE="/ramtmp/CDisPausing"

for i in "$@"
do
    case $i in
        -l|--loadcd)
            eject -t && checkcd.sh 
            touch $CDTRCL 
            touch $TR
            touch $CTR 
            echo "0" > $TR
            echo "0" > $TTR
            shift # past argument=value
            ;;
        -e|--eject)
            ejectcd.sh
            if [ -f $CDTRCL ]; then
                rm $CDPLAY
                rm $CDPAUSE
                #sleep 3
                checkcd.sh
            fi
            if [ -f $TOC ]; then
                ParseTOC.py -b > $TTR
                echo "1" > $CTR
            fi
            shift # past argument=value
            ;;
        -l|-l=*|--lib=*)
            LIBPATH="${i#*=}"
            echo "I'm here"
            shift # past argument=value
            ;;
        --default)
            DEFAULT=YES
            shift # past argument with no value
            ;;
        *)
            # unknown option
            ;;
    esac
done
