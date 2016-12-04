#!/bin/bash

arecord -d hw:1,0 | aplay -d hw:0,0 &  
