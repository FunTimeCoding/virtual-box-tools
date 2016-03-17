#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} VM_NAME"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
VM_NAME="${1}"

if [ "${VM_NAME}" = "" ]; then
    usage

    exit 1
fi

FOUND=true
"${SCRIPT_DIRECTORY}"/get-info.sh "${VM_NAME}" > /dev/null || FOUND=false

if [ "${FOUND}" = false ]; then
    echo "Not found: ${VM_NAME}"

    exit 1
fi

STATE=$("${SCRIPT_DIRECTORY}"/get-vm-state.sh "${VM_NAME}")

if [ ! "${STATE}" = "poweroff" ]; then
    "${SCRIPT_DIRECTORY}"/stop-vm.sh "${VM_NAME}"
    DOWN=false

    for SECOND in $(seq 1 30); do
        echo "${SECOND}"
        sleep 1
        STATE=$("${SCRIPT_DIRECTORY}"/get-vm-state.sh "${VM_NAME}")

        if [ "${STATE}" = "poweroff" ]; then
            DOWN=true

            break
        fi
    done

    if [ "${DOWN}" = "false" ]; then
        "${SCRIPT_DIRECTORY}"/stop-vm.sh --force "${VM_NAME}"
        sleep 3
    fi
fi

${MANAGE_COMMAND} unregistervm "${VM_NAME}" --delete
