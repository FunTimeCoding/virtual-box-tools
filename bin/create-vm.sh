#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} [--wait] VM_NAME"
}

. "${SCRIPT_DIR}/../lib/virtual_box_tools.sh"
WAIT=false

if [ "${1}" = "--wait" ]; then
    WAIT=true
    shift
fi

VM_NAME="${1}"

if [ "${VM_NAME}" = "" ]; then
    usage

    exit 1
fi

"${SCRIPT_DIR}"/clone-vm.sh jessie "${VM_NAME}"
"${SCRIPT_DIR}"/start-vm.sh "${VM_NAME}"

if [ "${WAIT}" = true ]; then
    echo "Wait for VM to finish booting."
    BOOT_TIME="0"

    for SECOND in $(seq 1 60); do
        sleep 1
        IP=$("${SCRIPT_DIR}"/get-vm-ip.sh "${VM_NAME}")

        if [ ! "${IP}" = "" ]; then
            BOOT_TIME="${SECOND}"
            break
        fi
    done

    MAC=$("${SCRIPT_DIR}"/get-vm-mac.sh --colons "${VM_NAME}")
    echo "BOOT_TIME: ${BOOT_TIME}"
    echo "IP: ${IP}"
    echo "MAC: ${MAC}"
else
    echo "VM is booting."
fi
