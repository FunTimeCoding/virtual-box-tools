#!/bin/sh -e

VM_NAME="${1}"
DESTINATION_HOST="${2}"

if [ "${VM_NAME}" = "" ] || [ "${DESTINATION_HOST}" = "" ]; then
    echo "Usage: VM_NAME DESTINATION_HOST"

    exit 1
fi

TEMPORARY_DIRECTORY="${HOME}/tmp/virtualbox"
mkdir -p "${TEMPORARY_DIRECTORY}"

if [ ! -d "${TEMPORARY_DIRECTORY}/${VM_NAME}" ]; then
    bin/stop-vm.sh --wait "${VM_NAME}"
    sudo cp -R "/home/vbox/VirtualBox VMs/${VM_NAME}" "${TEMPORARY_DIRECTORY}/${VM_NAME}"
    bin/start-vm.sh --wait "${VM_NAME}"
    sudo chown -R shiin:shiin "${TEMPORARY_DIRECTORY}/${VM_NAME}"
fi

rm -f "${TEMPORARY_DIRECTORY}/${VM_NAME}/${VM_NAME}.vbox-prev"
rm -rf "${TEMPORARY_DIRECTORY}/${VM_NAME}/Logs"
ssh "${DESTINATION_HOST}" mkdir -p tmp/virtualbox
rsync --archive --verbose --update --delete --progress "${TEMPORARY_DIRECTORY}/${VM_NAME}" "${DESTINATION_HOST}:${HOME}/tmp/virtualbox"
