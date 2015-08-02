#!/bin/sh -e

usage(){
    echo "Usage: ${0} VM_NAME"
}

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

NOT_FOUND=false
bin/show-info.sh "${1}" > /dev/null 2>&1 || NOT_FOUND=true

if [ "${NOT_FOUND}" = true ]; then
    echo "Not found."

    exit 1
else
    IS_RUNNING=$(bin/list-vms.sh | grep "${1}")

    if [ ! "${IS_RUNNING}" = "" ]; then
        echo "Stop vm."
        bin/stop-vm.sh "${1}"

        for SECOND in $(seq 1 120); do
            echo "${SECOND}"
            sleep 1
            STATE=$(vboxmanage showvminfo --machinereadable "${1}" | grep "VMState=")
            STATE=${STATE#*=}
            STATE=$(echo "${STATE}" | gsed 's/"//g')

            if [ "${STATE}" = "poweroff" ]; then

                break
            fi
        done
    fi
fi

vboxmanage unregistervm "${1}" --delete
