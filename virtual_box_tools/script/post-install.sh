#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive
apt-get --quiet 2 update
# dkms for additions, python-apt for Ansible to use check mode
apt-get --quiet 2 install dkms python3-apt
mount --options loop /dev/sr0 /mnt
EXIT_CODE='0'
REMOVE_INSTALLATION_DIR=0 yes | sh /mnt/VBoxLinuxAdditions.run --target /tmp/VBoxGuestAdditions || EXIT_CODE="${?}"

if [ "${EXIT_CODE}" = '2' ]; then
    echo "Ignore VBoxLinuxAdditions exit code 2."
else
    echo "VBoxLinuxAdditions exit code: ${EXIT_CODE}"

    exit "${EXIT_CODE}"
fi

umount /mnt
eject /dev/sr0
apt-get --quiet 2 autoremove
apt-get --quiet 2 clean
init 0
