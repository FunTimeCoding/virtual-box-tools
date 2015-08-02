#!/bin/sh -e

usage(){
    echo "Usage: ${0} VM_NAME"
}

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

NOT_FOUND=false
bin/show-vm-info.sh > /dev/null || NOT_FOUND=true

if [ "${NOT_FOUND}" = true ]; then
    echo "Not found."

    exit 1
else
    IS_RUNNING=$(bin/list-vms.sh | grep "${1}")

    if [ ! "${IS_RUNNING}" = "" ]; then
        echo "Stop vm."
        bin/stop-vm.sh "${1}"
    fi
fi

vboxmanage unregistervm "${1}" --delete
