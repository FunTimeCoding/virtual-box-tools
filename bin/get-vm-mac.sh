#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} [--colons] VM_NAME"
}

. "${SCRIPT_DIR}/../lib/virtual_box_tools.sh"
COLONS=false

if [ "${1}" = "--colons" ]; then
    COLONS=true
    shift
fi

VM_NAME="${1}"

if [ "${VM_NAME}" = "" ]; then
    usage

    exit 1
fi

KEY="MAC"
VALUE=$(${MANAGE_COMMAND} guestproperty enumerate "${VM_NAME}" | grep "${KEY}" || VALUE="")

if [ ! "${VALUE}" = "" ]; then
    VALUE="${VALUE#*value: }"
    VALUE="${VALUE%%,*}"

    if [ "${COLONS}" = "false" ]; then
        echo "${VALUE}"
    else
        LIST=$(echo "${VALUE}" | fold -w2)
        RESULT=""

        for HEX in ${LIST}; do
            RESULT="${RESULT}:${HEX}"
        done

        RESULT="${RESULT#:}"
        echo "${RESULT}"
    fi
fi
