#!/bin/bash


if [ -f /etc/cdplayer/phono ]; then
	KillAllAudio.sh
	arecord -f dat -D default:CODEC | aplay -D default:OutPlayer &
	log "Start pipe phono"
elif [ -f /etc/cdplayer/spdif1 ]; then
	rm /etc/cdplayer/spdif1
	touch /etc/cdplayer/spdif2
	log "set source spdif2"
elif [ -f /etc/cdplayer/spdif2 ]; then
	rm /etc/cdplayer/spdif2
	touch /etc/cdplayer/analog
	log "set source analog"
elif [ -f /etc/cdplayer/analog ]; then
	rm /etc/cdplayer/analog
	touch /etc/cdplayer/cdplayer
	log "set source cdplayer"
elif [ -f /etc/cdplayer/cdplayer ]; then
	rm /etc/cdplayer/cdplayer
	touch /etc/cdplayer/mpd
	log "set source mpd"
elif [ -f /etc/cdplayer/mpd ]; then
	rm /etc/cdplayer/mpd
	touch /etc/cdplayer/phono
	log "set source phono"
fi
