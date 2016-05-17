#!/bin/sh -e

MACHINE_NAME="${1}"

if [ "${MACHINE_NAME}" = "" ]; then
    echo "Usage: ${0} MACHINE_NAME"

    exit 1
fi

# Create machine.
vboxmanage createvm --name "${MACHINE_NAME}" --register

# Create disk.
DISK_NAME="${MACHINE_NAME}.vdi"
vboxmanage createhd --filename "${DISK_NAME}" --size 16384
vboxmanage storageattach "${MACHINE_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${DISK_NAME}"
vboxmanage storageattach "${MACHINE_NAME}" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium emptydrive

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
