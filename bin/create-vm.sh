#!/bin/sh -e

usage(){
    echo "Usage: ${0} VM_NAME"
}

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

bin/clone-vm.sh jessie "${1}"
bin/start-vm.sh "${1}"
bin/get-vm-ip.sh "${1}"

for SECOND in $(seq 1 120); do
    echo "${SECOND}"
    sleep 1
    IP=$(bin/get-vm-ip.sh "${1}")

    if [ ! "${IP}" = "" ]; then

        break
    fi
done

echo "${IP}"
