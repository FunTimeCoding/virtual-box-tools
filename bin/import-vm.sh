#!/bin/sh -e

PATH_TO_VM="${1}"

if [ "${PATH_TO_VM}" = "" ]; then
    echo "Usage: PATH_TO_VM"

    exit 1
fi

if [ ! -d "${PATH_TO_VM}" ]; then
    echo "Virtual machine not found: ${PATH_TO_VM}"

    exit 1
fi

sudo chown -R virtualbox:virtualbox "${PATH_TO_VM}"
VM_NAME=$(basename ${PATH_TO_VM})
BOX_DIRECTORY="/home/virtualbox/VirtualBox VMs"

if [ -f "${BOX_DIRECTORY}/${VM_NAME}" ]; then
    echo "Virtual machine already exists: ${BOX_DIRECTORY}/${VM_NAME}"

    exit 1
fi

sudo su - virtualbox
sudo mv "${PATH_TO_VM}" "${BOX_DIRECTORY}/${VM_NAME}"
vboxmanage registervm "${BOX_DIRECTORY}/${VM_NAME}/${VM_NAME}.vbox"
./bin/start-vm.sh --wait "${VM_NAME}"
