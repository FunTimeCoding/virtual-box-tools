#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} MACHINE_NAME"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
MACHINE_NAME="${1}"

if [ "${MACHINE_NAME}" = "" ]; then
    usage

    exit 1
fi

STATE=$(${MANAGE_COMMAND} showvminfo --machinereadable "${MACHINE_NAME}" | grep "VMState=")
STATE=${STATE#*=}
STATE=$(echo "${STATE}" | sed 's/"//g')
echo "${STATE}"
