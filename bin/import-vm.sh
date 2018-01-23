#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} MACHINE_NAME"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh

MACHINE_NAME="${1}"

if [ "${MACHINE_NAME}" = "" ]; then
    usage

    exit 1
fi

if [ "${SUDO_USER}" = "" ]; then
    HOME_DIRECTORY="${HOME}"
else
    HOME_DIRECTORY="/home/${SUDO_USER}"
fi

MACHINE_NAME=$(basename "${MACHINE_NAME}")
TEMPORARY_DIRECTORY="${HOME_DIRECTORY}/tmp/virtualbox"
BOX_DIRECTORY="${HOME_DIRECTORY}/VirtualBox VMs"

if [ ! -d "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}" ]; then
    echo "Virtual machine not found: ${TEMPORARY_DIRECTORY}/${MACHINE_NAME}"

    exit 1
fi

if [ -d "${BOX_DIRECTORY}/${MACHINE_NAME}" ]; then
    echo "Virtual machine already exists: ${BOX_DIRECTORY}/${MACHINE_NAME}"

    exit 1
fi

if [ "${SUDO_USER}" = "" ]; then
    mv "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}" "${BOX_DIRECTORY}/${MACHINE_NAME}"
else
    ${SUDO} mv "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}" "${BOX_DIRECTORY}/${MACHINE_NAME}"
fi

${VBOXMANAGE} registervm "${BOX_DIRECTORY}/${MACHINE_NAME}/${MACHINE_NAME}.vbox"
# TODO: Confirm this works some other time.
#vbt host start --name "${MACHINE_NAME}" --wait
