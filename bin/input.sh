#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} MACHINE_NAME LINE"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
MACHINE_NAME="${1}"
LINE="${2}"

if [ "${MACHINE_NAME}" = "" ] || [ "${LINE}" = "" ]; then
    usage

    exit 1
fi

SCAN_CODE=$("${SCRIPT_DIRECTORY}"/scan-code.py "${LINE}")
${VBOXMANAGE} controlvm "${MACHINE_NAME}" keyboardputscancode ${SCAN_CODE}
