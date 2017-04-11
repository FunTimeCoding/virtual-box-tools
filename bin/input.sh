#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} MACHINE_NAME TEXT"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
MACHINE_NAME="${1}"
TEXT="${2}"

if [ "${MACHINE_NAME}" = "" ] || [ "${TEXT}" = "" ]; then
    usage

    exit 1
fi

LINES=$("${SCRIPT_DIRECTORY}"/scan-code.py "${TEXT}")

for LINE in ${LINES}; do
    ${VBOXMANAGE} controlvm "${MACHINE_NAME}" keyboardputscancode ${LINE}
done
