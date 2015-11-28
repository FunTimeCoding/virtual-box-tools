#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} [--force] VM_NAME"
}

. "${SCRIPT_DIR}/../lib/virtual_box_tools.sh"
FORCE=false

if [ "${1}" = "--force" ]; then
    FORCE=true
    shift
fi

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

VM_NAME="${1}"

if [ "${FORCE}" = true ]; then
    ${MANAGE_COMMAND} controlvm "${VM_NAME}" poweroff
else
    ${MANAGE_COMMAND} controlvm "${VM_NAME}" acpipowerbutton
fi
