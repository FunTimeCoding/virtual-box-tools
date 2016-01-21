#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)
LIST=$(cat "${SCRIPT_DIR}/../running-vms.txt")

for ELEMENT in ${LIST}; do
    echo "${SCRIPT_DIR}/start-vm.sh ${ELEMENT}"
done
