#!/bin/bash

# Change these options
# Most arnt used yet ovbiously
cdrom="/dev/cdrom"
ripcommand="cdparanoia %track %out"
encodecommand="lame -S -q 2 -b 160 %in %out"
cdidcommand="cd-discid %cdrom"
freedbcommand="cddb-tool"
freedbserver="http://freedb.freedb.org/~cddb/cddb.cgi"

# Leave this alone
cddbuser=$(whoami)
cddbhost=$(hostname)

# Get the disk id
cd-discid $cdrom > /tmp/davidmp3script-cdid
# Get the query from freedb
cddb-tool query $freedbserver 5 $cddbuser $cddbhost $(cd-discid $cdrom) > /tmp/davidmp3script-query
cat /tmp/davidmp3script-query

# Get the genre from the query
responsecode=$(cat /tmp/davidmp3script-query | awk '{i++} i==1 {print ""$1""}')
case "$responsecode" in
    200)
        genre=$(cat /tmp/davidmp3script-query | awk '{print $2}')
        ;;
    210)
        genre=$(cat /tmp/davidmp3script-query | awk '{i++} i==2 {print ""$1""}')
        ;;
    202)
        echo "No results"
        ;;
esac

# Get the read from freedb
cddb-tool read $freedbserver 5 $cddbuser $cddbhost $genre $(cd-discid $cdrom) > /tmp/davidmp3script-read
cat /tmp/davidmp3script-read
