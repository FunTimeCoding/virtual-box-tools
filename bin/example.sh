#!/bin/sh -e

echo "Only contains example vboxmanage commands."
exit 1

VM_NAME="example"

# Create new VM.
vboxmanage createvm --name "${VM_NAME}" --register
# Enable ACPI.
vboxmanage modifyvm "${VM_NAME}" --acpi on
# Enable CPU hotplug while VM is stopped.
vboxmanage modifyvm "${VM_NAME}" --cpuhotplug on
# Hotplug a core while VM is running.
vboxmanage modifyvm "${VM_NAME}" --plugcpu 1
# Unplug a core while VM is running.
vboxmanage modifyvm "${VM_NAME}" --unplugcpu 1

DISK_NAME="example.vdi"
# Create a disk.
vboxmanage createhd --filename "${DISK_NAME}" --size 16384
# Change an existing disks size.
vboxmanage modifyhd "${DISK_PATH}" --resize 32768
# Attach a disk to a VM.
vboxmanage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "${DISK_NAME}"
# Alternative types: fdd (floppy), dvddrive
# An optical drive must exist.
vboxmanage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium emptydrive

# Create a network device. Enumeration starts with 1, not 0.
# Possible nictype values: http://www.virtualbox.org/manual/ch06.html#nichardware
vboxmanage modifyvm "${VM_NAME}" --nic1 nat --nictype1 82540EM
# Set address space.
vboxmanage modifyvm "${VM_NAME}" --natnet1 "192.168/16".
# Forward host port 2222 to guest port 22. FORWARD_NAME is an arbitrary string.
FORWARD_NAME="example ssh"
vboxmanage modifyvm "${VM_NAME}" --natpf1 "${FORWARD_NAME},tcp,,2222,,22"
# Remove a forward.
vboxmanage modifyvm "${VM_NAME}" --natpf1 delete "${FORWARD_NAME}"

OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = "Linux" ]; then
    TFTP_DIRECTORY="${HOME}/.config/VirtualBox/TFTP"
else
    TFTP_DIRECTORY="${HOME}/Library/VirtualBox/TFTP"
fi

# Use TFTP to automatically install a VM.
mkdir -p "${TFTP_DIRECTORY}"
cd "${TFTP_DIRECTORY}"
wget http://ftp.debian.org/debian/dists/jessie/main/installer-amd64/current/images/netboot/netboot.tar.gz
tar xf netboot.tar.gz
mkdir tmp
cd tmp
cat ../debian-installer/amd64/initrd.gz | gzip -d | sudo cpio -i
# Use debian-tools to generate preseed.cfg.
sudo wget http://www.golem.de/projekte/vbox/preseed.cfg
sudo chown root:wheel preseed.cfg
