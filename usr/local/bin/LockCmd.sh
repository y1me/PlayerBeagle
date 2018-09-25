#!/bin/bash

LOCK="/ramtmp/LockIHM"

log()
{
    logger -t LockIHM $1
}

if  [ "$1" = "ON" ]; then
    if [ ! -f $LOCK ]; then 
        touch $LOCK
    fi
    log "IHM locked"
    exit 0
fi

if  [ "$1" = "OFF" ]; then
    if [ -f $LOCK ]; then 
        rm $LOCK
    log "IHM unlocked"
    fi
fi

