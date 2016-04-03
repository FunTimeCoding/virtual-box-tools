#!/bin/sh -e

echo "Only contains example vboxmanage commands."
exit 1

# Enable CPU hotplug while VM is stopped.
vboxmanage modifyvm "${VM_NAME}" --cpuhotplug on
# Hotplug a core while VM is running.
vboxmanage modifyvm "${VM_NAME}" --plugcpu 1
# Unplug a core while VM is running.
vboxmanage modifyvm "${VM_NAME}" --unplugcpu 1

# Resize a disk.
vboxmanage modifyhd "${DISK_PATH}" --resize 32768

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
gzip -d < ../debian-installer/amd64/initrd.gz | sudo cpio -i
# Use debian-tools to generate preseed.cfg.
cd ~/Code/Personal/debian-tools
PYTHONPATH=. bin/dt --hostname example --domain example.org --root-password root --user-name shiin --user-password shiin --user-real-name "Alexander Reitzel" --insecure > preseed.cfg
sudo mv preseed.cfg "${TFTP_DIRECTORY}/tmp"
popd
sudo chown root:wheel preseed.cfg
find . | cpio -o --format=newc | gzip -9c > ../initrd.gz
cd ..
cp initrd.gz debian-installer/amd64
ln -s debian-installer/amd64/pxelinux.0 debian.pxe
vboxmanage modifyvm "${VM_NAME}" --nattftpfile1 /debian.pxe

echo "DEFAULT jessie
LABEL jessie
kernel debian-installer/amd64/linux
append vga=normal initrd=debian-installer/amd64/initrd.gz auto=true priority=critical preseed/file=/preseed.cfg" >> debian-installer/amd64/boot-screens/syslinux.cfg

vboxmanage modifyvm "${VM_NAME}" --boot1 net
vboxmanage startvm "${VM_NAME}" --type headless

vboxmanage modifyvm "${VM_NAME}" --boot1 disk
