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

CONTROLLER_NAME="SATA Controller"
${VBOXMANAGE} storageattach "${MACHINE_NAME}" --storagectl "${CONTROLLER_NAME}" --port 1 --device 0 --type dvddrive --medium additions
