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
CDSTATTR="/cdtmp/CDStatusTracks"
CDSTATTM="/cdtmp/CDStatusTime"
CDSTATPP="/cdtmp/CDStatusPercent"
CDDUMP="/cdtmp/"

NextTracksCD()
{
    if [ ! -f $CDPAUSE ] ; then
        LENGTHFILE=$(cat < $CDSTATTR) || exit
        if [ "${#LENGTHFILE}" -gt 25 ]; then
            echo >&2 "Invalid track info"
            exit 1
        else
            NEXTTRACK=$(cat $CDSTATTR | cut -d 'k' -f 2 | cut -d '.' -f 1)
            NEXTTRACK=$(echo "($NEXTTRACK + 1)" | bc)
            TOTALTRACKS=$(cat < $TTR) || exit
            if [ $NEXTTRACK -gt $TOTALTRACKS ]; then 
                NEXTTRACK=1
            fi
            if [ -f $CDPLAY ] ; then
                if [ ${#NEXTTRACK} -eq 1 ]; then
                    TRACKTOPLAY=$CDDUMP"track0"$NEXTTRACK".cdda.wav"
                else
                    TRACKTOPLAY=$CDDUMP"track"$NEXTTRACK".cdda.wav"
                fi
                if ls $NEXTTRACK".out" > /dev/null 2>&1; then
                    while [ $(stat -c%s $TRACKTOPLAY) -lt 300 ]; do
                        sleep 1
                    done
                else
                    pkill DumpCD.sh
                    pkill cdparanoia
                    DumpCD.sh $NEXTTRACK > /dev/null 2>&1 &
                    sleep 1
                    while [ $(stat -c%s $TRACKTOPLAY) -lt 300 ]; do
                        sleep 1
                    done
                fi

                NEXTTRACK=$(cat $CDSTATTR | cut -d 'k' -f 2 | cut -d '.' -f 1)
                NEXTTRACK=$(echo "($NEXTTRACK + 1)" | bc)
                if [ $NEXTTRACK -gt $TOTALTRACKS ]; then 
                    ((TOTALTRACKS=TOTALTRACKS-1))
                    echo "pt_step -"$TOTALTRACKS > $CDCTRL
                else
                    echo "pt_step 1" > $CDCTRL
                fi
            else
                echo $NEXTTRACK > $TR
            fi
        fi
    fi
}

PrevTracksCD()
{
    if [ ! -f $CDPAUSE ] ; then
        CURRENTTIME=$(cat $CDSTATTM | cut -d '=' -f 2 | cut -d '.' -f 1)
        if [ $CURRENTTIME -gt 5 ]; then
            echo "seek 0 1" > $CDCTRL
            exit 0
        fi
        LENGTHFILE=$(cat < $CDSTATTR) || exit
        if [ "${#LENGTHFILE}" -gt 25 ]; then
            echo >&2 "Invalid track info"
            exit 1
        else
            NEXTTRACK=$(cat $CDSTATTR | cut -d 'k' -f 2 | cut -d '.' -f 1)
            NEXTTRACK=$(echo "($NEXTTRACK - 1)" | bc)
            TOTALTRACKS=$(cat < $TTR) || exit
            if [ $NEXTTRACK -eq 0 ]; then 
                NEXTTRACK=$TOTALTRACKS
            fi
            if [ -f $CDPLAY ] ; then
                if [ ${#NEXTTRACK} -eq 1 ]; then
                    TRACKTOPLAY=$CDDUMP"track0"$NEXTTRACK".cdda.wav"
                else
                    TRACKTOPLAY=$CDDUMP"track"$NEXTTRACK".cdda.wav"
                fi

                if ls $NEXTTRACK".out" > /dev/null 2>&1; then
                    while [ $(stat -c%s $TRACKTOPLAY) -lt 300 ]; do
                        sleep 1
                    done
                else
                    pkill DumpCD.sh
                    pkill cdparanoia
                    DumpCD.sh $NEXTTRACK > /dev/null 2>&1 &
                    sleep 1
                    while [ $(stat -c%s $TRACKTOPLAY) -lt 300 ]; do
                        sleep 1
                    done
                fi
                NEXTTRACK=$(cat $CDSTATTR | cut -d 'k' -f 2 | cut -d '.' -f 1)
                NEXTTRACK=$(echo "($NEXTTRACK - 1)" | bc)
                if [ $NEXTTRACK -eq 0 ]; then 
                    ((TOTALTRACKS=TOTALTRACKS-1))
                    echo "pt_step "$TOTALTRACKS > $CDCTRL
                else
                    echo "pt_step -1" > $CDCTRL
                fi
            else
                echo $NEXTTRACK > $TR
            fi
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
    pkill -9 ReadCdStatus.sh
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
        STARTTRACK=$(cat $TR)
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
        if [ $STARTTRACK -gt 1 ]; then
            pkill DumpCD.sh
            pkill cdparanoia
            DumpCD.sh $(cat $TR) > /dev/null 2>&1 &
            while [ ! -f $($CDDUMP$( $CDDUMP | grep $(cat $TR))) ]; do
                sleep 1
            done
            while [ $(stat -c%s $CDDUMP$(ls $CDDUMP | grep $(cat $TR))) -lt 300 ]; do
                sleep 1
            done
        fi
        pkill mplayer
        sleep 1
        mplayer -nogui -nolirc -slave -quiet -input file=$CDCTRL -idle &>/ramtmp/mplayer.log 2>/ramtmp/mplayer-err.log &
        #mplayer -nogui -nolirc -slave -quiet -input file=$CDCTRL -idle &
        ENDTRACK=$(cat $TTR)
        sleep 1
        for i in $(seq -f "%02g" 1 $ENDTRACK); do
            echo "loadfile "$CDDUMP"track"$i".cdda.wav 1" > $CDCTRL
        done
        if [ $STARTTRACK -gt 1 ]; then
            ((STARTTRACK-=1))
            echo "pt_step $STARTTRACK"  > $CDCTRL

        fi
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
