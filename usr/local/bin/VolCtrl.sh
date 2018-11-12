#!/bin/bash
# from : https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

DIRPL="/etc/cdplayer"
VOLCF="/etc/cdplayer/Volume.conf"
MUTE="/ramtmp/mute"

# Log in syslog
log()
{
	logger -t ProcessIO $1
}

VOLUPManage()
{
    if [ ! -f $VOLCF ]; then
        mkdir $DIRPL
        touch $VOLCF
        echo "195" >> $VOLCF
    fi
    if [ -f $MUTE ]; then
        rm $MUTE 
        log "mute off"
        PCM1792AMute.sh OFF
    fi
    read -r vol < $VOLCF
    if  [ $vol -lt 255 ]; then
        vol=$(($vol +2))
        echo $vol > $VOLCF
        PCM1792AVolume.sh $vol >> /dev/null
        log "Volume send $vol"
        WriteInfo.sh -r $((($vol-255)/2))"db"
    else
        log "Volume max"
        WriteInfo.sh -r "0db"

    fi
}

VOLDWManage()
{
    if [ ! -f $VOLCF ]; then
        mkdir $DIRPL
        touch $VOLCF
        echo "195" >> $VOLCF
    fi
    if [ -f $MUTE ]; then
        rm $MUTE 
        log "mute off"
        PCM1792AMute.sh OFF
    fi
    read -r vol < $VOLCF
    if  [ $vol -gt 0 ]; then
        vol=$(($vol -2))
        echo $vol > $VOLCF
        PCM1792AVolume.sh $vol >> /dev/null
        log "Volume send $vol"
        WriteInfo.sh -r $((($vol-255)/2))"db"
    else
        log "Volume min"
        WriteInfo.sh -r "-128db"
    fi
}

MUTEManage()
{
    if [ ! -f $MUTE ]; then
        touch $MUTE 
        log "mute on"
        PCM1792AMute.sh ON
        WriteInfo.sh -r "mute"
    else
        rm $MUTE 
        log "mute off"
        PCM1792AMute.sh OFF
        WriteInfo.sh -r "sound"
    fi

}

VolumeInit()
{
    if [ ! -f $VOLCF ]; then
        mkdir $DIRPL
        touch $VOLCF
        echo "195" >> $VOLCF
    fi
    if [ -f $MUTE ]; then
        rm $MUTE 
        log "mute off"
    fi
    PCM1792AMute.sh OFF
    read -r vol < $VOLCF
    PCM1792AVolume.sh $vol >> /dev/null
    log "Volume send $vol"
}

for i in "$@"
do
    case $i in
        -i|--init)
            VolumeInit
            shift # past argument=value
            ;;
        -m|--mute)
            MUTEManage
            shift # past argument=value
            ;;
        -u|--up)
            VOLUPManage
            shift # past argument=value
            ;;
        -d|--down)
            VOLDWManage
            shift # past argument=value
            ;;
        *)
            # unknown option
            ;;
    esac
done
