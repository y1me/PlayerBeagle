#!/bin/sh

# Log in syslog
log()
{
    logger -t GpioInit $1
}

mkdir /gpio
if [ ! -d "/sys/class/gpio/gpio1" ]; then 
    echo 1 > /sys/class/gpio/export 
fi
ln -s /sys/class/gpio/gpio1 /gpio/UsbPW
log "Create gpio link"	
echo out > /gpio/UsbPW/direction
echo 1 > /gpio/UsbPW/value
log "config gpio out,high"	
