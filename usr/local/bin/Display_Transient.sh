#!/bin/bash

string=$1
INFOTR="/ramtmp/infotransientrunning"

pkill Display_Transient.sh
if [ ! -f $INFOTR ]; then
    touch $INFOTR
fi
sleep 0.5
WriteInfo.sh -r $1

sleep 3

rm $INFOTR
