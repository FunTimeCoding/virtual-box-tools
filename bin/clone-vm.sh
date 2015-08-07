#!/bin/sh -e

usage(){
    echo "Usage: ${0} EXISTING_NAME NEW_NAME"
}

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

if [ "${2}" = "" ]; then
    usage

    exit 1
fi

ERROR=false
OUTPUT=$(vboxmanage clonevm "${1}" --name "${2}" --register 2>&1) || ERROR=true

if [ "${ERROR}" = true ]; then
    echo "Error:"
    echo "${OUTPUT}"

    exit 1
fi
