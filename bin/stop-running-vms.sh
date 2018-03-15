#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
LIST=$(vbt host list | jq --raw-output '.[].name')
echo "${LIST}" > "${SCRIPT_DIRECTORY}"/../running-vms.txt

for ELEMENT in ${LIST}; do
    vbt host stop --name "${ELEMENT}" --wait
done
