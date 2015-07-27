#!/bin/sh -e

usage(){
    echo "Usage: ${0} VM_NAME"
}

if [ "${1}" = "" ]; then
    usage
    exit 1
fi

vboxmanage startvm "${1}" --type headless