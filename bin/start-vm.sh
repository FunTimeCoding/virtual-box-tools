#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} [--wait] MACHINE_NAME"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
WAIT=false

if [ "${1}" = "--wait" ]; then
    WAIT=true
    shift
fi

MACHINE_NAME="${1}"

if [ "${MACHINE_NAME}" = "" ]; then
    usage

    exit 1
fi

ERROR=false
OUTPUT=$(${VBOXMANAGE} startvm "${1}" --type headless 2>&1) || ERROR=true

if [ "${ERROR}" = true ]; then
    echo "Error:"
    echo "${OUTPUT}"

    exit 1
fi

if [ "${WAIT}" = true ]; then
    echo "Wait for virtual machine to be started."
    BOOT_TIME=0

    for SECOND in $(seq 1 60); do
        sleep 1
        LOGICAL_ADDRESS=$("${SCRIPT_DIRECTORY}"/get-vm-ip.sh "${MACHINE_NAME}")

        if [ ! "${LOGICAL_ADDRESS}" = "" ]; then
            BOOT_TIME="${SECOND}"
            break
        fi
    done

    PHYSICAL_ADDRESS=$("${SCRIPT_DIRECTORY}"/get-vm-mac.sh --colons "${MACHINE_NAME}")
    echo "BOOT_TIME: ${BOOT_TIME}"
    echo "IP: ${LOGICAL_ADDRESS}"
    echo "MAC: ${PHYSICAL_ADDRESS}"
else
    echo "Virtual machine '${MACHINE_NAME}' is starting."
fi
