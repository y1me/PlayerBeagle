# PlayerBeagle

## Set USB0 host

* get "https://github.com/RobertCNelson/bb-kernel"

* follow -> linux -> mainline : https://eewiki.net/display/linuxonarm/BeagleBone+Black
before run build_deb.sh : 
edit file "arch/arm/boot/dts/am335x-bone-common.dtsi"
 "usb0 -> dr_mode = "host";"
( remember "tools/rebuild_deb.sh")
* Deploy builded packages 

## Change soundcard name 
http://www.alsa-project.org/main/index.php/Changing_card_IDs_with_udev

## GPIO 
copy "gpioinit" to etc/init.d and run "update-rc.d gpioinit defaults"




