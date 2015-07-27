#!/bin/sh -e

usage(){
    echo "Usage: ${0} EXISTING_VM NEW_VM_NAME"
}

if [ "${0}" = "" ]; then
    usage
    exit 1
fi

if [ "${1}" = "" ]; then
    usage
    exit 1
fi

vboxmanage clonevm "${1}" --name "${2}" --register
