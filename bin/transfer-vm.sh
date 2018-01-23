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

if [ "${SUDO_USER}" = "" ]; then
    HOME_DIRECTORY="${HOME}"
else
    HOME_DIRECTORY="/home/${SUDO_USER}"
fi

TEMPORARY_DIRECTORY="${HOME_DIRECTORY}/tmp/virtualbox"

if [ "${SUDO_USER}" = "" ]; then
    mkdir -p "${TEMPORARY_DIRECTORY}"
else
    ${SUDO} mkdir -p "${TEMPORARY_DIRECTORY}"
fi

if [ ! -d "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}" ]; then
    # TODO: Extract running string properly.
    #STATE=$(vbt host show --name "${MACHINE_NAME}" | grep state)

    #if [ "${STATE}" = running ]; then
    #    vbt host stop --name "${MACHINE_NAME}" --wait
    #fi

    if [ "${SUDO_USER}" = "" ]; then
        cp -R "${HOME_DIRECTORY}/VirtualBox VMs/${MACHINE_NAME}" "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}"
    else
        ${SUDO} cp -R "${HOME_DIRECTORY}/VirtualBox VMs/${MACHINE_NAME}" "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}"
    fi

    # TODO: Add option to not start it anymore if it uses a static address.
    #if [ "${STATE}" = running ]; then
    #    vbt host start --name "${MACHINE_NAME}" --wait
    #fi
fi

if [ "${SUDO_USER}" = "" ]; then
    rm -f "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}/${MACHINE_NAME}.vbox-prev"
    rm -rf "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}/Logs"
    ssh "${DESTINATION_HOST}" mkdir -p tmp/virtualbox
    rsync --archive --verbose --update --delete --progress "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}" "${DESTINATION_HOST}:${HOME}/tmp/virtualbox"
else
    ${SUDO} rm -f "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}/${MACHINE_NAME}.vbox-prev"
    ${SUDO} rm -rf "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}/Logs"
    ssh "${SUDO_USER}@${DESTINATION_HOST}" mkdir -p tmp/virtualbox
    ${SUDO} rsync --archive --verbose --update --delete --progress "${TEMPORARY_DIRECTORY}/${MACHINE_NAME}" "${SUDO_USER}@${DESTINATION_HOST}:${HOME}/tmp/virtualbox"
fi
