#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} VM_NAME FORWARDING_NAME"
}

. "${SCRIPT_DIR}/../lib/virtual_box_tools.sh"
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
