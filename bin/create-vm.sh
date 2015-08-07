#!/bin/sh -e

SCRIPT_DIR=$(cd "$(dirname "${0}")"; pwd)

usage(){
    echo "Usage: ${0} [--wait] VM_NAME"
}

WAIT=false

if [ "${1}" = "--wait" ]; then
    WAIT=true
    shift
fi

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

"${SCRIPT_DIR}/clone-vm.sh" jessie "${1}"
"${SCRIPT_DIR}/start-vm.sh" "${1}"

if [ "${WAIT}" = "true" ]; then
    echo "Wait for IP."

    for SECOND in $(seq 1 60); do
        sleep 1
        IP=$("${SCRIPT_DIR}/get-vm-ip.sh" "${1}")

        if [ ! "${IP}" = "" ]; then

            break
        fi
    done

    MAC=$("${SCRIPT_DIR}/get-vm-mac.sh" --colons "${1}")
    echo "IP: ${IP}"
    echo "MAC: ${MAC}"
else
    echo "VM is booting."
fi