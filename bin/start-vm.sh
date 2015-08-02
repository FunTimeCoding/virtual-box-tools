#!/bin/sh -e

usage(){
    echo "Usage: ${0} VM_NAME"
}

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

COMMAND_FAILED=false
OUTPUT=$(vboxmanage startvm "${1}" --type headless) || COMMAND_FAILED=true

if [ "${COMMAND_FAILED}" = "true" ]; then
    echo "Error:"
    echo "${OUTPUT}"

    exit 1
fi
