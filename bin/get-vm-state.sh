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

STATE=$(${MANAGE_COMMAND} showvminfo --machinereadable "${VM_NAME}" | grep "VMState=")
STATE=${STATE#*=}
STATE=$(echo "${STATE}" | sed 's/"//g')
echo "${STATE}"
