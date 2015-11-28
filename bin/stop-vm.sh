#!/bin/sh -e

usage()
{
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

VM_NAME="${1}"

if [ "${FORCE}" = true ]; then
    vboxmanage controlvm "${VM_NAME}" poweroff
else
    vboxmanage controlvm "${VM_NAME}" acpipowerbutton
fi
