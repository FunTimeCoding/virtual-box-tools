#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} VM_NAME"
}

. "${SCRIPT_DIR}/../lib/virtual_box_tools.sh"
VM_NAME="${1}"

if [ "${VM_NAME}" = "" ]; then
    usage

    exit 1
fi

KEY="IP"
VALUE=$(${MANAGE_COMMAND} guestproperty enumerate "${VM_NAME}" | grep "${KEY}" || VALUE="")

if [ ! "${VALUE}" = "" ]; then
    VALUE="${VALUE#*value: }"
    VALUE="${VALUE%%,*}"
    echo "${VALUE}"
fi
