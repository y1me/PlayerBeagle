#!/bin/bash
# from : https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
for i in "$@"
do
    case $i in
        -l|--loadcd)
            eject -t && checkcd.sh 
            touch /ramtmp/CDTrayClose
            touch /ramtmp/Tracks
            touch /ramtmp/Ttracks
            echo "0" > /ramtmp/Tracks
            echo "0" > /ramtmp/Ttracks
            shift # past argument=value
            ;;
        -e|--eject)
            eject
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
