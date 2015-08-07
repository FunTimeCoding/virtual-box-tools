#!/bin/sh -e

usage(){
    echo "Usage: ${0} [--colons] VM_NAME"
}

COLONS=false

if [ "${1}" = "--colons" ]; then
    COLONS=true
    shift
fi

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

KEY="MAC"
VALUE=$(vboxmanage guestproperty enumerate "${1}" | grep "${KEY}" || VALUE="")

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
