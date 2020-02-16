#!/bin/bash

if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

if [[ $EUID -ne 0 ]]; then
    echo "You must be a root user" 
    exit 1
else
    echo "You are root"
fi

apt update
apt install i2c-tools -y
apt install abcde -y 
apt install cd-discid -y

pkill DumpCD.sh
pkill cdparanoia

cp -r ./usr /
cp -r ./etc /
cp -r ./boot /

rm /ramtmp/*
rm /cdtmp/*

systemctl daemon-reload
systemctl restart ReadIHM.service
systemctl restart ProcessIO.service
echo "Copy done!"
