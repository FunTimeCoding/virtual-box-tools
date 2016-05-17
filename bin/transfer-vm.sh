#!/bin/sh -e

MACHINE_NAME="${1}"
DESTINATION_HOST="${2}"

if [ "${MACHINE_NAME}" = "" ] || [ "${DESTINATION_HOST}" = "" ]; then
    echo "Usage: MACHINE_NAME DESTINATION_HOST"

    exit 1
fi

TEMPORARY_DIRECTORY="${HOME}/tmp/virtualbox"
mkdir -p "${TEMPORARY_DIRECTORY}"

if [ ! -d "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}" ]; then
    bin/stop-vm.sh --wait "${MACHINE_NAME}"
    sudo cp -R "/home/vbox/VirtualBox VMs/${MACHINE_NAME}" "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}"
    bin/start-vm.sh --wait "${MACHINE_NAME}"
    sudo chown -R shiin:shiin "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}"
fi

rm -f "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}/${MACHINE_NAME}.vbox-prev"
rm -rf "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}/Logs"
ssh "${DESTINATION_HOST}" mkdir -p tmp/virtualbox
rsync --archive --verbose --update --delete --progress "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}" "${DESTINATION_HOST}:${HOME}/tmp/virtualbox"
