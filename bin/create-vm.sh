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

"${SCRIPT_DIRECTORY}"/clone-vm.sh jessie "${MACHINE_NAME}"
"${SCRIPT_DIRECTORY}"/start-vm.sh "${MACHINE_NAME}"

if [ "${WAIT}" = true ]; then
    echo "Wait for VM to finish booting."
    BOOT_TIME="0"

    for SECOND in $(seq 1 60); do
        sleep 1
        IP=$("${SCRIPT_DIRECTORY}"/get-vm-ip.sh "${MACHINE_NAME}")

        if [ ! "${IP}" = "" ]; then
            BOOT_TIME="${SECOND}"
            break
        fi
    done

    MAC=$("${SCRIPT_DIRECTORY}"/get-vm-mac.sh --colons "${MACHINE_NAME}")
    echo "BOOT_TIME: ${BOOT_TIME}"
    echo "IP: ${IP}"
    echo "MAC: ${MAC}"
else
    echo "VM is booting."
fi
