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
MACHINE_NAME=$(basename ${PATH_TO_VM})
BOX_DIRECTORY="/home/virtualbox/VirtualBox VMs"

if [ -f "${BOX_DIRECTORY}/${MACHINE_NAME}" ]; then
    echo "Virtual machine already exists: ${BOX_DIRECTORY}/${MACHINE_NAME}"

    exit 1
fi

sudo mv "${PATH_TO_VM}" "${BOX_DIRECTORY}/${MACHINE_NAME}"
${MANAGE_COMMAND} registervm "${BOX_DIRECTORY}/${MACHINE_NAME}/${MACHINE_NAME}.vbox"
"${DIRECTORY}"/start-vm.sh --wait "${MACHINE_NAME}"
