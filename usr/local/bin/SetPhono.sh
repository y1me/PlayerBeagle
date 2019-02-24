#!/bin/bash

arecord -f dat -Dhw:CARD=CODEC,DEV=0 | aplay &  

exit 0
