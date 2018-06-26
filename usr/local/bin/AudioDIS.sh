#!/bin/bash
echo out > /gpio/AudioOutPW/direction && echo 0 > /gpio/AudioOutPW/value
echo out > /gpio/UsbPW/direction && echo 0 > /gpio/UsbPW/value
