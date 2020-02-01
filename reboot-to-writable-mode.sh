#/bin/sh
mount -o remount,rw /overlay/root-ro
touch /overlay/root-ro/disable-root-ro
reboot
