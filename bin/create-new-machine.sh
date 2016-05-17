#!/bin/sh -e

PRESEED_FILE="${1}"
MACHINE_NAME="${2}"
RELEASE="${3}"

if [ "${PRESEED_FILE}" = "" ] || [ "${MACHINE_NAME}" = "" ]; then
    echo "Usage: ${0} PRESEED_FILE MACHINE_NAME [RELEASE]"
    echo "RELEASE can be jessie, wheezy, squeeze. Default is jessie."

    exit 1
fi

if [ "${RELEASE}" = "" ]; then
    RELEASE=jessie
fi

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

if [ "${OPERATING_SYSTEM}" = "Darwin" ]; then
    TRIVIAL_DIRECTORY="${HOME}/Library/VirtualBox/TFTP"
else
    TRIVIAL_DIRECTORY="${HOME}/.config/VirtualBox/TFTP"
fi

rm -rf "${TRIVIAL_DIRECTORY:?}"
mkdir "${TRIVIAL_DIRECTORY}"
cp "${PRESEED_FILE}" "${TRIVIAL_DIRECTORY}/preseed.cfg"
cd "${TRIVIAL_DIRECTORY}"
NETWORK_BOOT_ARCHIVE="${HOME}/tmp/netboot-${RELEASE}.tar.gz"

if [ ! -f "${NETWORK_BOOT_ARCHIVE}" ]; then
    wget --output-document "${NETWORK_BOOT_ARCHIVE}" "http://ftp.debian.org/debian/dists/${RELEASE}/main/installer-amd64/current/images/netboot/netboot.tar.gz"
fi

tar xf "${NETWORK_BOOT_ARCHIVE}" --directory "${TRIVIAL_DIRECTORY}"
mkdir tmp
cd tmp
gzip -d < ../debian-installer/amd64/initrd.gz | sudo cpio -i
sudo cp ../preseed.cfg .

if [ "${OPERATING_SYSTEM}" = "Darwin" ]; then
    sudo chown root:wheel preseed.cfg
else
    sudo chown root:root preseed.cfg
fi

find . | cpio -o --format=newc | gzip -9c > ../initrd.gz
cd ..
cp initrd.gz debian-installer/amd64
ln -s debian-installer/amd64/pxelinux.0 debian.pxe
vboxmanage modifyvm "${MACHINE_NAME}" --nattftpfile1 /debian.pxe
echo "DEFAULT ${RELEASE}
LABEL ${RELEASE}
kernel debian-installer/amd64/linux
append vga=normal initrd=debian-installer/amd64/initrd.gz auto=true priority=critical preseed/file=/preseed.cfg" >> debian-installer/amd64/boot-screens/syslinux.cfg
vboxmanage modifyvm "${MACHINE_NAME}" --boot1 net
vboxmanage startvm "${MACHINE_NAME}" --type headless
# TODO: Wait for machine to be stopped, then change boot1 to disk.
#vboxmanage modifyvm "${MACHINE_NAME}" --boot1 disk
