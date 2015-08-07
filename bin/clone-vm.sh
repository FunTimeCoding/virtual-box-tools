#!/bin/sh -e

usage(){
    echo "Usage: ${0} EXISTING_VM NEW_VM_NAME"
}

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

if [ "${2}" = "" ]; then
    usage

    exit 1
fi

COMMAND_FAILED=false
OUTPUT=$(vboxmanage clonevm "${1}" --name "${2}" --register 2>&1) || COMMAND_FAILED=true

if [ "${COMMAND_FAILED}" = "true" ]; then
    echo "Error:"
    echo "${OUTPUT}"

    exit 1
fi
