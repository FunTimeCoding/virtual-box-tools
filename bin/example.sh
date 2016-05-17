#!/bin/sh -e

echo "Only contains example vboxmanage commands."
exit 1

# CPU hot plug.
# Enable CPU hot plugging. Machine must be stopped.
vboxmanage modifyvm "${MACHINE_NAME}" --cpuhotplug on
# Add a core. Machine can be running.
vboxmanage modifyvm "${MACHINE_NAME}" --plugcpu 1
# Remove a core. Machine can be running.
vboxmanage modifyvm "${MACHINE_NAME}" --unplugcpu 1


# Resize a disk.
vboxmanage modifyhd "${DISK_PATH}" --resize 32768


# Set the network interface controller type.
# Available nictype values: http://www.virtualbox.org/manual/ch06.html#nichardware
vboxmanage modifyvm "${MACHINE_NAME}" --nic1 nat --nictype1 82540EM


# Set address space of a NAT network.
vboxmanage modifyvm "${MACHINE_NAME}" --natnet1 "192.168/16".


# Forwards
# Forward host port 2222 to guest port 22. FORWARD_NAME is an arbitrary string.
FORWARD_NAME="example ssh"
vboxmanage modifyvm "${MACHINE_NAME}" --natpf1 "${FORWARD_NAME},tcp,,2222,,22"
# Remove a forward.
vboxmanage modifyvm "${MACHINE_NAME}" --natpf1 delete "${FORWARD_NAME}"
