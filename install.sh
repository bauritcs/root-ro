#!/bin/sh

# Error out if anything fails.
set -e

# Make sure script is run as root.
if [ "$(id -u)" != "0" ]; then
  echo "Must be run as root with sudo! Try: sudo ./install.sh"
  exit 1
fi

if ! grep -q "^overlay" /etc/initramfs-tools/modules; then
  echo Adding \"overlay\" to /etc/initramfs-tools/modules ...
  echo overlay >> /etc/initramfs-tools/modules
fi

echo Setting up maintenance scripts in /usr/local/sbin ...
cp reboot-to-readonly-mode.sh /usr/local/sbin/reboot-to-readonly-mode.sh
chmod +x /usr/local/sbin/reboot-to-readonly-mode.sh

cp reboot-to-writable-mode.sh /usr/local/sbin/reboot-to-writable-mode.sh
chmod +x /usr/local/sbin/reboot-to-writable-mode.sh

echo Setting up initramfs-tools scripts ...
cp etc/initramfs-tools/scripts/init-bottom/root-ro /etc/initramfs-tools/scripts/init-bottom/root-ro
chmod +x /etc/initramfs-tools/scripts/init-bottom/root-ro

cp etc/initramfs-tools/hooks/root-ro /etc/initramfs-tools/hooks/root-ro
chmod +x /etc/initramfs-tools/hooks/root-ro

echo Updating initramfs ...
update-initramfs -u

if ! grep GRUB_CMDLINE_LINUX /etc/default/grub | grep -q "root-ro-driver=overlay" ; then
  echo Adding root-ro-driver parameter to /etc/default/grub ...
  sed -e 's/^GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="root-ro-driver=overlay /' -i /etc/default/grub
  echo Updating grub.cfg ...
  update-grub
fi

echo Restarting ...
reboot
