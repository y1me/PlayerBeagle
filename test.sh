#!/bin/bash

echo $0
echo $@
echo $?

PWD=$(pwd)

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

echo $PWD

cp -r ./usr /
