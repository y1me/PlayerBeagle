#!/bin/bash
echo out > /gpio/AudioOutPW/direction && echo 1 > /gpio/AudioOutPW/value
echo out > /gpio/UsbPW/direction && echo 1 > /gpio/UsbPW/value
