#!/bin/sh -e

PRESEED_FILE="${1}"
MACHINE_NAME="${2}"

if [ "${PRESEED_FILE}" = "" ] || [ "${MACHINE_NAME}" = "" ]; then
    echo "Usage: ${0} PRESEED_FILE MACHINE_NAME"

    exit 1
fi

#vboxmanage list ostypes
vboxmanage createvm --name "${MACHINE_NAME}" --register --ostype Debian_64

CONTROLLER_NAME="SATA Controller"
vboxmanage storagectl "${MACHINE_NAME}" --name "${CONTROLLER_NAME}" --add sata

DISK_NAME="${MACHINE_NAME}.vdi"
MACHINE_DIRECTORY="${HOME}/VirtualBox VMs/${MACHINE_NAME}"
DISK_PATH="${MACHINE_DIRECTORY}/${DISK_NAME}"
vboxmanage createmedium disk --filename "${DISK_PATH}" --size 16384

vboxmanage storageattach "${MACHINE_NAME}" --storagectl "${CONTROLLER_NAME}" --port 0 --device 0 --type hdd --medium "${DISK_PATH}"
vboxmanage storageattach "${MACHINE_NAME}" --storagectl "${CONTROLLER_NAME}" --port 1 --device 0 --type dvddrive --medium emptydrive

vboxmanage modifyvm "${MACHINE_NAME}" --acpi on
OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = "Linux" ]; then
    TFTP_DIRECTORY="${HOME}/.config/VirtualBox/TFTP"
else
    TFTP_DIRECTORY="${HOME}/Library/VirtualBox/TFTP"
fi

mkdir -p "${TFTP_DIRECTORY}/tmp"
cp "${PRESEED_FILE}" "${TFTP_DIRECTORY}/preseed.cfg"
cd "${TFTP_DIRECTORY}"

if [ ! -f netboot.tar.gz ]; then
    wget http://ftp.debian.org/debian/dists/jessie/main/installer-amd64/current/images/netboot/netboot.tar.gz
fi

if [ ! -f version.info ]; then
    tar xf netboot.tar.gz
fi

cd tmp

if [ ! -d bin ]; then
    gzip -d < ../debian-installer/amd64/initrd.gz | sudo cpio -i
fi

sudo cp ../preseed.cfg .

if [ "${OPERATING_SYSTEM}" = "Linux" ]; then
    sudo chown root:root preseed.cfg
else
    sudo chown root:wheel preseed.cfg
fi

find . | cpio -o --format=newc | gzip -9c > ../initrd.gz
cd ..
cp initrd.gz debian-installer/amd64

if [ ! -L debian.pxe ]; then
    ln -s debian-installer/amd64/pxelinux.0 debian.pxe
fi

# Point NAT network at the TFTP file.
vboxmanage modifyvm "${MACHINE_NAME}" --nattftpfile1 /debian.pxe

echo "DEFAULT jessie
LABEL jessie
kernel debian-installer/amd64/linux
append vga=normal initrd=debian-installer/amd64/initrd.gz auto=true priority=critical preseed/file=/preseed.cfg" >> debian-installer/amd64/boot-screens/syslinux.cfg

# Boot from network for installation.
vboxmanage modifyvm "${MACHINE_NAME}" --boot1 net


vboxmanage startvm "${MACHINE_NAME}" --type headless
vboxmanage modifyvm "${MACHINE_NAME}" --boot1 disk
