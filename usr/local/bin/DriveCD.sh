#!/bin/bash
# from : https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

CDTRCL="/ramtmp/CDTrayClose"
TOC="/ramtmp/toc"
CDCTRL="/tmp/cdcontrol"
TTR="/ramtmp/Ttracks"
TR="/ramtmp/Tracks"
CTR="/ramtmp/Ctracks"
CDCMD="/ramtmp/CDCommandisPending"
CDPLAY="/ramtmp/CDisPlaying"
CDPAUSE="/ramtmp/CDisPausing"
CDSTATTR="/cdtmp/CDStatusTracks"
CDSTATTM="/cdtmp/CDStatusTime"
CDSTATPP="/cdtmp/CDStatusPercent"
CDDUMP="/cdtmp/"

log()
{
    logger -t DriveCD $1
}

NextTracksCD()
{
    if [ ! -f $CDPAUSE ] ; then
        log "jump next track"
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
        log "jump previous track"
        CURRENTTIME=$(cat $CDSTATTM | cut -d '=' -f 2 | cut -d '.' -f 1)
        if [ $CURRENTTIME -gt 5 ]; then
            echo "seek 0 1" > $CDCTRL
            if [ -f $CDCMD ]; then 
                rm $CDCMD
                log "DriveCD unlock"
            fi
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
    log "Close tray and load CD"
    eject -t && checkcd.sh 
    touch $CDTRCL 
    touch $TR
    touch $CTR 
    if [ -f $TOC ]; then
        rm $CDDUMP* 
        ParseTOC.py -b > $TTR				
        echo "1" > $CTR
        echo "1" > $TR
        DumpCD.sh 1 > /dev/null 2>&1 &
    fi
}
StopCD()
{
    log "Stop playing CD"
    pkill -9 mplayer
    pkill -9 ReadCdStatus.sh
    if [ -f $CDPLAY ]; then
        rm $CDPLAY
    fi
    if [ -f $CDPAUSE ]; then
        rm $CDPAUSE
    fi
}

CleanDump()
{
    for i in $( eval echo {1..$(cat $TTR)} )
    do
        if [ ! -f "$CDDUMP$i.out" ]; then 
            if [ ${#i} -eq 1 ]; then
                DMPTR=$CDDUMP"track0"$i".cdda.wav"
            else
                DMPTR=$CDDUMP"track"$i".cdda.wav"
            fi
            if [ -f $DMPTR ]; then
                rm $DMPTR
            fi
        fi
    done
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
        log "play cd"
        STARTTRACK=$(cat $TR)
        pkill mplayer
        pkill ReadCdStatus.sh
        CleanDump
        #if [ ! -f $CDDUMP"1.out" ]; then
        pkill DumpCD.sh
        pkill cdparanoia
        log "kill previous process"
        log "Rip CD in RAM"
        DumpCD.sh 1 > /dev/null 2>&1 &
        #fi
        while [ ! -f $CDDUMP"track01.cdda.wav" ]; do
            sleep 1
            log "wait track n°1 creation"
        done
        while [ $(stat -c%s $CDDUMP"track01.cdda.wav") -lt 300 ]; do
            sleep 1
            log "wait track n°1 first data"
        done
        if [ $STARTTRACK -gt 1 ]; then
            if [ ! -f "$CDDUMP$(cat $TR).out" ]; then
                pkill DumpCD.sh
                pkill cdparanoia
                DumpCD.sh $(cat $TR) > /dev/null 2>&1 &
                log "RIP CD in RAM"
                log "Don't start from track n°1 - kill previous process"
            fi
            while [ ! -f $($CDDUMP$( $CDDUMP | grep $(cat $TR))) ]; do
                sleep 1
                log "Don't start from track n°1 - wait track X creation"
            done
            while [ $(stat -c%s $CDDUMP$(ls $CDDUMP | grep $(cat $TR))) -lt 300 ]; do
                sleep 1
                log "Don't start from track n°1 -wait trackX first data"
            done
        fi
        sleep 1
        mplayer -nogui -nolirc -slave -quiet -input file=$CDCTRL -idle &>/ramtmp/mplayer.log 2>/ramtmp/mplayer-err.log &
        log "mplayer started"
        #mplayer -nogui -nolirc -slave -quiet -input file=$CDCTRL -idle &
        ENDTRACK=$(cat $TTR)
        sleep 0.3
        TRACKLIST=$(seq -f "%02g" 1 $ENDTRACK)
        log "Track list : $TRACKLIST"
        COUNTER=1
        while [  $COUNTER -le $ENDTRACK ]; do
            #echo "The counter is $COUNTER"
            #echo "loadfile "$CDDUMP"track"$(printf %02g $COUNTER)".cdda.wav 1" > $CDCTRL
            echo "loadfile "$CDDUMP"track"$(printf %02g $COUNTER)".cdda.wav 1" > $CDCTRL
            ((COUNTER=COUNTER+1)) 
            sleep 0.3
        done
         #   echo "loadfile "$CDDUMP"track"$i".cdda.wav 1" > $CDCTRL
         #  log "loadfile "$CDDUMP"track"$i".cdda.wav 1"
            log "Playlist loaded"
        if [ $STARTTRACK -gt 1 ]; then
            ((STARTTRACK-=1))
            echo "pt_step $STARTTRACK"  > $CDCTRL

        fi
        ReadCdStatus.sh &
        log "Start CD supervisor"
        touch $CDPLAY
        log "job done"
    else
        if [ ! -f $CDPAUSE ]; then
            log "pause cd"
            touch $CDPAUSE
            sleep 0.5
            echo "pause" > $CDCTRL
        else
            log "resume cd"
            rm $CDPAUSE
            echo "pause" > $CDCTRL
        fi

    fi
}

if [ -f $CDCMD ]; then 
    log "Discard DriveCD command"
    exit 1
else 
    log "DriveCD lock"
    touch $CDCMD
fi

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
            rm -rf $CDCTRL
            if [ -f $CDTRCL ]; then
                rm $CDPLAY
                rm $CDPAUSE
                #sleep 3
                checkcd.sh
            else
                rm $TOC 
                rm $CDDUMP* 
                if [ ! -f $MUTE ]; then
                    touch $MUTE
                fi
                PCM1792AMute.sh ON
                log "eject cd, mute on"
            fi
            if [ -f $TOC ]; then
                ParseTOC.py -b > $TTR
                echo "1" > $CTR
                echo "1" > $TR
                DumpCD.sh 1 > /dev/null 2>&1 &
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
            if [ ! -f $MUTE ]; then
                touch $MUTE
            fi
            PCM1792AMute.sh ON
            log "stop cd, mute on"
            shift # past argument=value
            ;;
        -p|--play)
            PlayPauseCD
            if [ -f $MUTE ]; then
                rm $MUTE
            fi
            PCM1792AMute.sh OFF
            log "play cd, mute off"
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

if [ -f $CDCMD ]; then 
    rm $CDCMD
    log "DriveCD unlock"
fi
