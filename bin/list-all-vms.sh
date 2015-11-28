#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} [--raw]"
}

. "${SCRIPT_DIR}/../lib/virtual_box_tools.sh"

if [ "${1}" = "--raw" ]; then
    ${MANAGE_COMMAND} list vms
else
    ${MANAGE_COMMAND} list vms | awk -F '"' '{ print $2 }'
fi
