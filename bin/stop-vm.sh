#!/bin/sh -e

usage(){
    echo "Usage: ${0} [--force] VM_NAME"
}

FORCE=false

if [ "${1}" = "--force" ]; then
    FORCE=true
    shift
fi

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

if [ "${FORCE}" = "true" ]; then
    vboxmanage controlvm "${1}" poweroff
else
    vboxmanage controlvm "${1}" acpipowerbutton
fi
