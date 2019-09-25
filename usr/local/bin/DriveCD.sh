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
    CurrentTrack=$(wc -m $TR | cut -d " " -f1)
    if [ $CurrentTrack -eq 2 ]; then
        NextTrack=$(cat $TR)
        ((NextTrack+=1))
        if ls $CDDUMP"track0"$NextTrack".cdda.wav"; then
            while [ $(stat -c%s $CDDUMP"track0"$NextTrack".cdda.wav") -lt 300 ]; do
                sleep 1
            done
            echo echo "pt_step 1" > $CDCTRL
        else
            pkill DumpCD.sh
            pkill cdparanoia
            DumpCD.sh $NextTrack > /dev/null 2>&1 &
            sleep 1
            while [ $(stat -c%s $CDDUMP"track0"$NextTrack".cdda.wav") -lt 300 ]; do
                sleep 1
            done
            echo echo "pt_step 1" > $CDCTRL

        fi
    fi
    if [ $CurrentTrack -eq 3 ]; then
        NextTrack=$(cat $TR)
        ((NextTrack+=1))
        if ls $CDDUMP"track"$NextTrack".cdda.wav"; then
            while [ $(stat -c%s $CDDUMP"track"$NextTrack".cdda.wav") -lt 300 ]; do
                sleep 1
            done
            echo echo "pt_step 1" > $CDCTRL
        else
            pkill DumpCD.sh
            pkill cdparanoia
            DumpCD.sh $NextTrack > /dev/null 2>&1 &
            sleep 1
            while [ $(stat -c%s $CDDUMP"track"$NextTrack".cdda.wav") -lt 300 ]; do
                sleep 1
            done
            echo echo "pt_step 1" > $CDCTRL
        fi
    fi
}

PrevTracksCD()
{
    CurrentTrack=$(wc -m $TR | cut -d " " -f1)
    if [ $CurrentTrack -eq 2 ]; then
        PrevTrack=$(cat $TR)
        ((PrevTRACK-=1))
        if ls $CDDUMP"track0"$PrevTrack".cdda.wav"; then
            while [ $(stat -c%s $CDDUMP"track0"$PrevTrack".cdda.wav") -lt 300 ]; do
                sleep 1
            done
            echo echo "pt_step 1" > $CDCTRL
        else
            pkill DumpCD.sh
            pkill cdparanoia
            DumpCD.sh $PrevTrack > /dev/null 2>&1 &
            sleep 1
            while [ $(stat -c%s $CDDUMP"track0"$PrevTrack".cdda.wav") -lt 300 ]; do
                sleep 1
            done
            echo echo "pt_step 1" > $CDCTRL

        fi
    fi
    if [ $CurrentTrack -eq 3 ]; then
        PrevTrack=$(cat $TR)
        ((PrevTRACK-=1))
        if ls $CDDUMP"track"$PrevTrack".cdda.wav"; then
            while [ $(stat -c%s $CDDUMP"track"$PrevTrack".cdda.wav") -lt 300 ]; do
                sleep 1
            done
            echo echo "pt_step -1" > $CDCTRL
        else
            pkill DumpCD.sh
            pkill cdparanoia
            DumpCD.sh $PrevTrack > /dev/null 2>&1 &
            sleep 1
            while [ $(stat -c%s $CDDUMP"track"$PrevTrack".cdda.wav") -lt 300 ]; do
                sleep 1
            done
            echo echo "pt_step -1" > $CDCTRL
        fi
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
        rm $CDDUMP* 
        pkill ReadCdStatus.sh
        pkill DumpCD.sh
        pkill cdparanoia
        DumpCD.sh 1 > /dev/null 2>&1 &
        while [ ! -f $CDDUMP"track01.cdda.wav" ]; do
            sleep 1
        done
        while [ $(stat -c%s $CDDUMP"track01.cdda.wav") -lt 300 ]; do
            sleep 1
        done
        pkill DumpCD.sh
        pkill cdparanoia
        DumpCD.sh $(cat $TR) > /dev/null 2>&1 &
        while [ ! -f $($CDDUMP$( $CDDUMP | grep $(cat $TR))) ]; do
            sleep 1
        done
        while [ $(stat -c%s $CDDUMP$(ls $CDDUMP | grep $(cat $TR))) -lt 300 ]; do
            sleep 1
        done
        pkill mplayer
        sleep 1
        mplayer -nogui -nolirc -slave -quiet -input file=$CDCTRL -idle &>/ramtmp/mplayer.log 2>/ramtmp/mplayer-err.log &
        #mplayer -nogui -nolirc -slave -quiet -input file=$CDCTRL -idle &
        STARTTRACK=$(cat $TR)
        ((STARTTRACK-=1))
        ENDTRACK=$(cat $TTR)
        for i in $(seq -f "%02g" 1 $ENDTRACK); do
            echo "loadfile "$CDDUMP"track"$i".cdda.wav 1" > $CDCTRL
        done
        echo "pt_step $STARTTRACK"  > $CDCTRL
        ReadCdStatus.sh &
        touch $CDPLAY
    else
        if [ ! -f $CDPAUSE ]; then
            touch $CDPAUSE
            sleep 0.5
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
