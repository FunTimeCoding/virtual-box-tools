#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} VM_NAME"
}

. "${SCRIPT_DIR}/../lib/virtual_box_tools.sh"
VM_NAME="${1}"

if [ "${VM_NAME}" = "" ]; then
    usage

    exit 1
fi

FOUND=true
"${SCRIPT_DIR}"/show-info.sh "${VM_NAME}" > /dev/null || FOUND=false

if [ "${FOUND}" = false ]; then
    echo "Not found: ${VM_NAME}"

    exit 1
fi

IS_RUNNING=$("${SCRIPT_DIR}"/list-vms.sh | grep "${VM_NAME}") || IS_RUNNING=""

if [ ! "${IS_RUNNING}" = "" ]; then
    echo "Stop vm."
    "${SCRIPT_DIR}"/stop-vm.sh "${VM_NAME}"
    DOWN=false

    for SECOND in $(seq 1 30); do
        echo "${SECOND}"
        sleep 1
        STATE=$("${SCRIPT_DIR}"/get-vm-state.sh "${VM_NAME}")

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

${MANAGE_COMMAND} unregistervm "${VM_NAME}" --delete
