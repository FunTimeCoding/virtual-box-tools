#!/bin/sh -e

usage(){
    echo "Usage: ${0} VM_NAME"
}

if [ "${1}" = "" ]; then
    usage
    exit 1
fi

vboxmanage guestproperty enumerate "${1}" | grep IP | grep -owPe '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
