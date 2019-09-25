#!/bin/bash
# from : https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

CDTRCL="/ramtmp/CDTrayClose"
TOC="/ramtmp/toc"
CDCTRL="/ramtmp/cdcontrol"
TTR="/ramtmp/Ttracks"
TR="/ramtmp/Tracks"
CTR="/ramtmp/Ctracks"
CDPLAY="/ramtmp/CDisPlaying"
CDPAUSE="/ramtmp/CDisPausing"
CDDUMP="/cdtmp/"

NextTracksCD()
{
    if [ -f $CDPLAY ]; then
        echo "seek_chapter 1 0" > $CDCTRL
    fi
}

PrevTracksCD()
{
    if [ -f $CDPLAY ]; then
        echo "seek_chapter -1 0" > $CDCTRL
    fi
}

LoadCD()
{
    eject -t && checkcd.sh 
    touch $CDTRCL 
    touch $TR
    touch $CTR 
    echo "0" > $TR
    if [ -f $TOC ]; then
        ParseTOC.py -b > $TTR				
        echo "1" > $CTR
    fi
}
StopCD()
{
    pkill -9 mplayer
    if [ -f $CDPLAY ]; then
        rm $CDPLAY
    fi
    if [ -f $CDPAUSE ]; then
        rm $CDPAUSE
    fi
}

PlayPauseCD()
{
    if [ ! -f $CDTRCL ]; then
        LoadCD
        if [ ! -f $TOC ]; then
            exit
        fi
    fi
    if [ ! -e $CDCTRL ] ; then
        mkfifo $CDCTRL
    fi
    if [ ! -f $CDPLAY ]; then
        DumpCD.sh $(cat $TR) > /dev/null 2>&1 &
        mplayer -nogui -nolirc -slave -quiet -input file=$CDCTRL -idle &>/ramtmp/mplayer.log 2>/ramtmp/mplayer-err.log &
        CurrentTrack=$(wc -m $TR | cut -d " " -f1)
        if [ $CurrentTrack -eq 2 ]; then
            CurrentTrack=$(cat $TR)
            echo "loadfile "$CDDUMP"track0"$CurrentTrack".cdda.wav" > $CDCTRL
        fi
        if [ $CurrentTrack -eq 3 ]; then
            CurrentTrack=$(cat $TR)
            echo "loadfile "$CDDUMP"track"$CurrentTrack".cdda.wav" > $CDCTRL
        fi
        touch $CDPLAY
    else
        if [ ! -f $CDPAUSE ]; then
            touch $CDPAUSE
            echo "pause" > $CDCTRL
        else
            rm $CDPAUSE
            echo "pause" > $CDCTRL
        fi

    fi
}

for i in "$@"
do
    case $i in
        -l|--loadcd)
            LoadCD
            shift # past argument=value
            ;;
        -e|--eject)
            StopCD
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
        -n|--next)
            NextTracksCD
            shift # past argument=value
            ;;
        -r|--previous)
            PrevTracksCD
            shift # past argument=value
            ;;
        -s|--stop)
            StopCD
            shift # past argument=value
            ;;
        -p|--play)
            PlayPauseCD
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
