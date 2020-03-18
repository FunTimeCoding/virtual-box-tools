#!/bin/sh -e

NAME="${1}"

if [ "${NAME}" = "" ]; then
    echo "Usage: ${0} NAME"

    exit 1
fi

vbt host create --name "${NAME}"
sleep 5
vbt host start --name "${NAME}"
sleep 60
vbt host show --name "${NAME}"
sleep 5
vbt host stop --name "${NAME}"
echo \\007

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
echo \\007
