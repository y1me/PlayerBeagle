#!/bin/bash
# from : https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

CDTRCL="/ramtmp/CDTrayClose"
TOC="/ramtmp/toc"
TTR="/ramtmp/Ttracks"
TR="/ramtmp/Tracks"
CTR="/ramtmp/Ctracks"
CDPLAY="/ramtmp/CDisPlaying"
CDPAUSE="/ramtmp/CDisPausing"

# Play/Pause CD
playpause()
{
	if [ -f $CDMD ]; then
		if [ ! -f $CDTRCL ]; then
			ejectcd.sh
			#sleep 3
			checkcd.sh
		
			if [ -f $TOC ]; then
				ParseTOC.py -b > $TTR				
				echo "1" > $CTR
			fi
		fi
	fi
	if [ ! -e $CDCTRL ] ; then
		mkfifo $CDCTRL
	fi
	if [ ! -f $CDPLAY ]; then
		if aplay -l | grep "OutPlayer" | grep "card 0" &>/dev/null; then
			mplayer -slave  --cdrom-device=/dev/cdrom --cdda=paranoia=2 cdda://$(cat $CTR)-$(cat $TTR) -ao alsa:device=hw=0.0  -input file=$CDCTRL -idle &>/ramtmp/mplayer.log 2>/ramtmp/mplayer-err.log -cache 1000 &
		else
			mplayer -slave  --cdrom-device=/dev/cdrom --cdda=paranoia=2 cdda://$(cat $CTR)-$(cat $TTR) -ao alsa:device=hw=1.0  -input file=$CDCTRL -idle &>/ramtmp/mplayer.log 2>/ramtmp/mplayer-err.log -cache 1000 &
		fi
		touch $CDPLAY
		WriteInfo.sh -s play
	else
		if [ ! -f $CDPAUSE ]; then
			touch $CDPAUSE
			echo "pause" > $CDCTRL
			WriteInfo.sh -s pause
		else
			rm $CDPAUSE
			echo "pause" > $CDCTRL
			WriteInfo.sh -s play
		fi
			
	fi
		
}

# Previous Tracks CD
prevtracks()
{
	if [ -f $CDMD ]; then
		if [ -f $CDPLAY ]; then
			echo "seek_chapter -1 0" > $CDCTRL
		fi
	fi

}

# Next Tracks CD
nexttracks()
{
	if [ -f $CDMD ]; then
		if [ -f $CDPLAY ]; then
			echo "seek_chapter 1 0" > $CDCTRL
		fi
	fi

}

# Stop CD
stopcd()
{
	if [ -f $CDMD ]; then
		if [ -f $CDPLAY ]; then
			pkill mplayer
			rm $CDPLAY
		fi
		if [ -f $CDPAUSE ]; then
			rm $CDPAUSE
		fi
		WriteInfo.sh -r stop
	fi

}

# Eject CD
eject()
{
            ejectcd.sh
            if [ -f $CDTRCL ]; then
                rm $CDPLAY
                rm $CDPAUSE
                #sleep 3
                checkcd.sh
            fi
            if [ -f $TOC ]; then
                ParseTOC.py -b | bc > $TTR
                echo "1" > $CTR
            fi
        }

for i in "$@"
do
    case $i in
        -l|--free)
            shift # past argument=value
            ;;
        -e|--eject)
            eject
            shift # past argument=value
            ;;
        -p|--pplay)
            playpause
            shift # past argument=value
            ;;
        -p|--prev)
            prevtracks
            shift # past argument=value
            ;;
        -n|--next)
            nexttracks
            shift # past argument=value
            ;;
        -s|--stop)
            stopcd
            shift # past argument=value
            ;;
StopCD()
        --default)
            DEFAULT=YES
            shift # past argument with no value
            ;;
        *)
            # unknown option
            ;;
    esac
done
