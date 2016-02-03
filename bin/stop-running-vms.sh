#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
FILE="${SCRIPT_DIRECTORY}"/../running-vms.txt
"${SCRIPT_DIRECTORY}"/list-vms.sh > "${FILE}"
LIST=$(cat "${SCRIPT_DIRECTORY}"/../running-vms.txt)

for ELEMENT in ${LIST}; do
    "${SCRIPT_DIRECTORY}"/stop-vm.sh "${ELEMENT}"
done
