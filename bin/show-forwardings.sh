#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} VM_NAME"
}

. "${SCRIPT_DIR}/../lib/virtual_box_tools.sh"

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

${MANAGE_COMMAND} showvminfo "${1}" --details --machinereadable | grep Forwarding
