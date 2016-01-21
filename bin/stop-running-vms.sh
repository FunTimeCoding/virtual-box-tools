#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)
FILE="${SCRIPT_DIR}/../running-vms.txt"
"${SCRIPT_DIR}"/list-vms.sh > "${FILE}"
LIST=$(cat "${SCRIPT_DIR}/../running-vms.txt")

for ELEMENT in ${LIST}; do
    echo "${SCRIPT_DIR}/stop-vm.sh ${ELEMENT}"
done
