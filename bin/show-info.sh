#!/bin/sh -e

usage()
{
    echo "Usage: ${0} NAME"
}

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

ERROR=false
OUTPUT=$(vboxmanage showvminfo "${1}" 2>&1) || ERROR=true

if [ "${ERROR}" = false ]; then
    echo "${OUTPUT}"
else
    echo "Error:"
    echo "${OUTPUT}"

    exit 1
fi
