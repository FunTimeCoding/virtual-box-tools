#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} [--colons] MACHINE_NAME"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
COLONS=false

if [ "${1}" = "--colons" ]; then
    COLONS=true
    shift
fi

MACHINE_NAME="${1}"

if [ "${MACHINE_NAME}" = "" ]; then
    usage

    exit 1
fi

KEY="MAC"
VALUE=$(${MANAGE_COMMAND} guestproperty enumerate "${MACHINE_NAME}" | grep "${KEY}" || VALUE="")

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
