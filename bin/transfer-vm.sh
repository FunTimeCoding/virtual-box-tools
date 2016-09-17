#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} MACHINE_NAME DESTINATION_HOST"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
MACHINE_NAME="${1}"
DESTINATION_HOST="${2}"

if [ "${MACHINE_NAME}" = "" ] || [ "${DESTINATION_HOST}" = "" ]; then
    usage

    exit 1
fi

TEMPORARY_DIRECTORY="${HOME}/tmp/virtualbox"
mkdir -p "${TEMPORARY_DIRECTORY}"

if [ ! -d "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}" ]; then
    STATE=$("${SCRIPT_DIRECTORY}"/get-vm-state.sh)

    if [ "${STATE}" = running ]; then
        echo "Stop running machine"
        "${SCRIPT_DIRECTORY}"/bin/stop-vm.sh --wait "${MACHINE_NAME}"
    fi

    if [ "${SUDO_USER}" = "" ]; then
        HOME_DIRECTORY="${HOME}"
    else
        HOME_DIRECTORY="/home/${SUDO_USER}"
    fi

    echo "Make local copy of machine"
    sudo cp -R "${HOME_DIRECTORY}/VirtualBox VMs/${MACHINE_NAME}" "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}"

    if [ "${STATE}" = running ]; then
        echo "Start machine again"
        "${SCRIPT_DIRECTORY}"/bin/start-vm.sh --wait "${MACHINE_NAME}"
    fi

    sudo chown -R shiin:shiin "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}"
fi

rm -f "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}/${MACHINE_NAME}.vbox-prev"
rm -rf "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}/Logs"
echo "Transfer machine to destination server"
ssh "${DESTINATION_HOST}" mkdir -p tmp/virtualbox
rsync --archive --verbose --update --delete --progress "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}" "${DESTINATION_HOST}:${HOME}/tmp/virtualbox"
