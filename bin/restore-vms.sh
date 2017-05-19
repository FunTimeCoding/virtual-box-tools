#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
LIST=$(cat "${SCRIPT_DIRECTORY}"/../running-vms.txt)

for ELEMENT in ${LIST}; do
    "${SCRIPT_DIRECTORY}"/start-vm.sh "${ELEMENT}"
    sleep 30
done
