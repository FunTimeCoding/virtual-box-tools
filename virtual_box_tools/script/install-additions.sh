#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive
apt-get --quiet 2 update
apt-get --quiet 2 install dkms
mount --options loop /dev/sr0 /mnt
yes | sh /mnt/VBoxLinuxAdditions.run
umount /mnt
eject /dev/sr0
# Clear leases. Otherwise the client will not let go of the temporary address
#  it receives during installation.
rm /var/lib/dhcp/*
<<<<<<< HEAD
# This might help avoid problems with dclient.
echo 'pre-up sleep 2' >> /etc/network/interface
=======
echo 'pre-up sleep 2' >> /etc/network/interfaces
>>>>>>> add missing s
init 0
