#include <stdio.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <linux/cdrom.h>

int main(int argc,char **argv) {
  int cdrom;
  int status=1;

/* gcc -o trayopen trayopen.c */
/* Print Open if cd tray is open */
/*
#include <sys/ioctl.h>
#include <linux/cdrom.h>

int result=ioctl(fd, CDROM_DRIVE_STATUS, CDSL_NONE);

switch(result) {
  case CDS_NO_INFO: ... break;
  case CDS_NO_DISC: ... break;
  case CDS_TRAY_OPEN: ... break;
  case CDS_DRIVE_NOT_READY: ... break;
  case CDS_DISC_OK: ... break;
*/

  if (! argv[1] ){
    printf("Usage : trayopen [device]\n");
    printf("Result: Returns a 0 if the tray was open and 1 if it was closed\n");
    exit(2);
  }

  if ((cdrom = open(argv[1],O_RDONLY | O_NONBLOCK)) < 0) {
    printf("Unable to open device %s. Provide a device name (/dev/sr0, /dev/cdrom) as a parameter.\n",argv[1]);
    exit(2);
  }
  /* Check CD tray status */
  if (ioctl(cdrom,CDROM_DRIVE_STATUS) == CDS_NO_DISC) {
    status=10;
  }

  if (ioctl(cdrom,CDROM_DRIVE_STATUS) == CDS_NO_INFO) {
    status=15;
  }

  if (ioctl(cdrom,CDROM_DRIVE_STATUS) == CDS_TRAY_OPEN) {
    status=20;
  }
  
  if (ioctl(cdrom,CDROM_DRIVE_STATUS) == CDS_DRIVE_NOT_READY) {
    status=25;
  }
  
  if (ioctl(cdrom,CDROM_DRIVE_STATUS) == CDS_DISC_OK) {
    status=30;
  }
  close(cdrom);
  exit(status);
}
