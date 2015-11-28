#!/bin/sh -e

usage()
{
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

EXISTING_NAME="${1}"
NEW_NAME="${2}"
ERROR=false
OUTPUT=$(vboxmanage clonevm "${EXISTING_NAME}" --name "${NEW_NAME}" --register 2>&1) || ERROR=true

if [ "${ERROR}" = true ]; then
    echo "Error:"
    echo "${OUTPUT}"

    exit 1
fi
