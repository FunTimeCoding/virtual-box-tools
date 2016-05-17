#!/bin/sh -e

MACHINE_NAME="${1}"

if [ "${MACHINE_NAME}" = "" ]; then
    echo "Usage: ${0} MACHINE_NAME"

    exit 1
fi

# Create machine.
# vboxmanage list ostypes
vboxmanage createvm --name "${MACHINE_NAME}" --register --ostype Debian_64

# Create a controller.
CONTROLLER_NAME="SATA Controller"
vboxmanage storagectl "${MACHINE_NAME}" --name "${CONTROLLER_NAME}" --add sata

# Create a disk.
DISK_NAME="${MACHINE_NAME}.vdi"
MACHINE_DIRECTORY="${HOME}/VirtualBox VMs/${MACHINE_NAME}"
DISK_PATH="${MACHINE_DIRECTORY}/${DISK_NAME}"
vboxmanage createmedium disk --filename "${DISK_PATH}" --size 16384

# Attach hard disk and DVD drive to the controller.
vboxmanage storageattach "${MACHINE_NAME}" --storagectl "${CONTROLLER_NAME}" --port 0 --device 0 --type hdd --medium "${DISK_PATH}"
vboxmanage storageattach "${MACHINE_NAME}" --storagectl "${CONTROLLER_NAME}" --port 1 --device 0 --type dvddrive --medium emptydrive

# Modify settings.
vboxmanage modifyvm "${MACHINE_NAME}" --acpi on
#vboxmanage modifyvm "${MACHINE_NAME}" --nic1 nat --nictype1 82540EM
#vboxmanage modifyvm "${MACHINE_NAME}" --nattftpfile1 /debian.pxe

# Boot from network for installation.
#vboxmanage modifyvm "${MACHINE_NAME}" --boot1 net

# Start setup.
vboxmanage startvm "${MACHINE_NAME}" --type headless

# Boot from disk first.
#vboxmanage modifyvm "${MACHINE_NAME}" --boot1 disk
