#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive
apt-get --quiet 2 update
apt-get --quiet 2 install dkms
mount --options loop /dev/sr0 /mnt
yes | sh /mnt/VBoxLinuxAdditions.run
umount /mnt
eject /dev/sr0
rm /var/lib/dhcp/*
init 0