#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} PATH_TO_VM"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh

PATH_TO_VM="${1}"

if [ "${PATH_TO_VM}" = "" ]; then
    usage

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

sudo mv "${PATH_TO_VM}" "${BOX_DIRECTORY}/${VM_NAME}"
${MANAGE_COMMAND} registervm "${BOX_DIRECTORY}/${VM_NAME}/${VM_NAME}.vbox"
"${DIRECTORY}"/start-vm.sh --wait "${VM_NAME}"
