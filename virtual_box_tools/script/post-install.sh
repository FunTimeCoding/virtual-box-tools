#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive
apt-get --quiet 2 update
# dkms for additions, python-apt for Ansible
apt-get --quiet 2 install dkms python-apt
mount --options loop /dev/sr0 /mnt
yes | sh /mnt/VBoxLinuxAdditions.run
umount /mnt
eject /dev/sr0
apt-get --quiet 2 autoremove
apt-get --quiet 2 clean
init 0
