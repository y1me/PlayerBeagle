#!/bin/bash

freedbcommand="cddb-tool"
freedbserver="http://freedb.freedb.org/~cddb/cddb.cgi"
QRY="/tmp/cddb-tool-query"
TOC="/ramtmp/toc"

# Leave this alone
cddbuser=$(whoami)
cddbhost=$(hostname)

# Get the query from freedb
cddb-tool query $freedbserver 5 $cddbuser $cddbhost $(cd-discid) > $QRY 

# Get the genre from the query
responsecode=$(cat $QRY | awk '{i++} i==1 {print ""$1""}')
case "$responsecode" in
    200)
        genre=$(cat $QRY | awk '{print $2}')
        ;;
    210)
        genre=$(cat $QRY | awk '{i++} i==2 {print ""$1""}')
        ;;
    202)
        echo "No results"
        ;;
esac

# Get the read from freedb
cd-discid > $TOC
cddb-tool read $freedbserver 5 $cddbuser $cddbhost $genre $(cd-discid) >> $TOC 
