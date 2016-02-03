#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} VM_NAME FORWARDING_NAME"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
VM_NAME="${1}"

if [ "${VM_NAME}" = "" ]; then
    usage

    exit 1
fi

FORWARDING_NAME="${2}"

if [ "${FORWARDING_NAME}" = "" ]; then
    usage

    exit 1
fi

${MANAGE_COMMAND} modifyvm "${VM_NAME}" --natpf1 delete "${FORWARDING_NAME}"
