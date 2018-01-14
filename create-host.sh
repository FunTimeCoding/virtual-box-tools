#!/bin/sh -e

NAME="${1}"
INTERFACE="${1}"

if [ "${NAME}" = "" ] || [ "${INTERFACE}" = "" ]; then
    echo "Usage: ${0} NAME INTERFACE"

    exit 1
fi

vbt host create --name "${NAME}" --bridge-interface "${INTERFACE}"
sleep 5
vbt host start --name "${NAME}"
sleep 60
vbt host show --name "${NAME}"
sleep 5
vbt host stop --name "${NAME}"
echo -ne '\007'

while true; do
    echo "Network configured? y/N"
    read -r READ

    if [ "${READ}" = y ]; then
        break
    fi
done

vbt host start --name "${NAME}"
sleep 60
bin/bootstrap-wrapper.sh "${NAME}"
echo -ne '\007'
