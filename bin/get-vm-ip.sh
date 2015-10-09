#!/bin/sh -e

usage()
{
    echo "Usage: ${0} VM_NAME"
}

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

KEY="IP"
VALUE=$(vboxmanage guestproperty enumerate "${1}" | grep "${KEY}" || VALUE="")

if [ ! "${VALUE}" = "" ]; then
    VALUE="${VALUE#*value: }"
    VALUE="${VALUE%%,*}"
    echo "${VALUE}"
fi
