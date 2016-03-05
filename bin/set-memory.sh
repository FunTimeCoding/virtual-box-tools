#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} VM_NAME MEMORY"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
VM_NAME="${1}"
MEMORY="${2}"

if [ "${VM_NAME}" = "" ] || [ "${MEMORY}" == "" ]; then
    usage

    exit 1
fi

${MANAGE_COMMAND} modifyvm "${VM_NAME}" --memory "${MEMORY}"
