#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} [--verbose] VM_NAME"
}

if [ "${1}" = "--verbose" ]; then
    set -x
    shift
fi

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

VM_NAME="${1}"
FOUND=true
"${SCRIPT_DIR}"/show-info.sh "${VM_NAME}" > /dev/null || FOUND=false

if [ "${FOUND}" = true ]; then
    IS_RUNNING=$("${SCRIPT_DIR}"/list-vms.sh | grep "${VM_NAME}") || IS_RUNNING=""

    if [ ! "${IS_RUNNING}" = "" ]; then
        echo "Stop vm."
        "${SCRIPT_DIR}"/stop-vm.sh "${VM_NAME}"
        DOWN=false

        for SECOND in $(seq 1 30); do
            echo "${SECOND}"
            sleep 1
            STATE=$(vboxmanage showvminfo --machinereadable "${VM_NAME}" | grep "VMState=")
            STATE=${STATE#*=}
            STATE=$(echo "${STATE}" | sed 's/"//g')

            if [ "${STATE}" = "poweroff" ]; then
                DOWN=true

                break
            fi
        done

        if [ "${DOWN}" = "false" ]; then
            echo "Force shutdown."
            "${SCRIPT_DIR}"/stop-vm.sh --force "${VM_NAME}"
            sleep 3
        fi
    fi

    vboxmanage unregistervm "${VM_NAME}" --delete
else
    echo "Not found: ${VM_NAME}"
fi
