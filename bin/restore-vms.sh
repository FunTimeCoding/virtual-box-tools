#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
LIST=$(cat "${SCRIPT_DIRECTORY}"/../running-vms.txt)

for ELEMENT in ${LIST}; do
    vbt host start --name "${ELEMENT}"
    sleep 30
done
