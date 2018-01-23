#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} PATH_TO_MACHINE"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh

PATH_TO_MACHINE="${1}"

if [ "${PATH_TO_MACHINE}" = "" ]; then
    usage

    exit 1
fi

if [ ! -d "${PATH_TO_MACHINE}" ]; then
    echo "Virtual machine not found: ${PATH_TO_MACHINE}"

    exit 1
fi

MACHINE_NAME=$(basename "${PATH_TO_MACHINE}")

if [ "${SUDO_USER}" = "" ]; then
    BOX_DIRECTORY="${HOME}/VirtualBox VMs"
else
    sudo chown -R "${SUDO_USER}:${SUDO_USER}" "${PATH_TO_MACHINE}"
    BOX_DIRECTORY="/home/${SUDO_USER}/VirtualBox VMs"
fi

if [ -f "${BOX_DIRECTORY}/${MACHINE_NAME}" ]; then
    echo "Virtual machine already exists: ${BOX_DIRECTORY}/${MACHINE_NAME}"

    exit 1
fi

sudo mv "${PATH_TO_MACHINE}" "${BOX_DIRECTORY}/${MACHINE_NAME}"
${VBOXMANAGE} registervm "${BOX_DIRECTORY}/${MACHINE_NAME}/${MACHINE_NAME}.vbox"
# TODO: Confirm this works some other time.
#vbt host start --name "${MACHINE_NAME}" --wait
