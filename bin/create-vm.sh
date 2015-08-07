#!/bin/sh -e

SCRIPT_DIR=$(cd "$(dirname "${0}")"; pwd)

usage(){
    echo "Usage: ${0} VM_NAME"
}

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

"${SCRIPT_DIR}/clone-vm.sh" jessie "${1}"
"${SCRIPT_DIR}/start-vm.sh" "${1}"

echo "Wait for IP."
for SECOND in $(seq 1 60); do
    sleep 1
    IP=$("${SCRIPT_DIR}/get-vm-ip.sh" "${1}")
    MAC=$("${SCRIPT_DIR}/get-vm-mac.sh" --colons "${1}")

    if [ ! "${IP}" = "" ]; then

        break
    fi
done

echo "IP: ${IP}"
