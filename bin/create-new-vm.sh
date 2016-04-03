#!/bin/sh -e

VM_NAME="${1}"

if [ "${VM_NAME}" = "" ]; then
    echo "Usage: ${0} VM_NAME"

    exit 1
fi

# Create machine.
vboxmanage createvm --name "${VM_NAME}" --register

# Create disk.
DISK_NAME="${VM_NAME}.vdi"
vboxmanage createhd --filename "${DISK_NAME}" --size 16384
vboxmanage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${DISK_NAME}"
vboxmanage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium emptydrive

# Modify settings.
vboxmanage modifyvm "${VM_NAME}" --acpi on
#vboxmanage modifyvm "${VM_NAME}" --nic1 nat --nictype1 82540EM
#vboxmanage modifyvm "${VM_NAME}" --nattftpfile1 /debian.pxe

# Temporarily boot from network first.
#vboxmanage modifyvm "${VM_NAME}" --boot1 net

# Start setup.
#vboxmanage startvm "${VM_NAME}" --type headless

# Boot from disk first.
#vboxmanage modifyvm "${VM_NAME}" --boot1 disk
