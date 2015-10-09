#!/bin/sh -e

usage()
{
    echo "Usage: ${0} VM_NAME FORWARDING_NAME"
}

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

if [ "${2}" = "" ]; then
    usage

    exit 1
fi

vboxmanage modifyvm "${1}" --natpf1 delete "${2}"
