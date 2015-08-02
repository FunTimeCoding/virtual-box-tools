#!/bin/sh -e

SCRIPT_DIR=$(cd "$(dirname "${0}")"; pwd)

usage(){
    echo "Usage: ${0} VM_NAME"
}

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

bin/clone-vm.sh jessie "${1}"
bin/start-vm.sh "${1}"

echo "Wait for IP."
for SECOND in $(seq 1 60); do
    sleep 1
    IP=$("${SCRIPT_DIR}/bin/get-vm-ip.sh" "${1}")

    if [ ! "${IP}" = "" ]; then

        break
    fi
done

echo "IP: ${IP}"
