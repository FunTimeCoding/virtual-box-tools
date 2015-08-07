#!/bin/sh -e

usage(){
    echo "Usage: ${0} NAME"
}

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

ERROR=false
OUTPUT=$(vboxmanage startvm "${1}" --type headless 2>&1) || ERROR=true

if [ "${ERROR}" = true ]; then
    echo "Error:"
    echo "${OUTPUT}"

    exit 1
fi
