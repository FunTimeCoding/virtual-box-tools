#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} MACHINE_NAME [PORT|off]"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
MACHINE_NAME="${1}"

if [ "${MACHINE_NAME}" = "" ]; then
    usage

    exit 1
fi

PORT="${2}"

if [ "${PORT}" = "" ]; then
    OUTPUT=$(${VBOXMANAGE} showvminfo "${MACHINE_NAME}" --details --machinereadable | grep vrde)
    VALUE=$(echo "${OUTPUT#*vrde=}" | xargs)
    echo "${VALUE}"
elif [ "${PORT}" = off ]; then
    ${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --vrde off
else
    ${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --vrde on
    ${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --vrdeport "${PORT}"
fi
