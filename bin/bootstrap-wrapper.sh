#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} HOST USER_PASSWORD ROOT_PASSWORD PROXY MASTER MINION_IDENTIFIER"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh

HOST="${1}"
USER_PASSWORD="${2}"
ROOT_PASSWORD="${3}"
PROXY="${4}"
MASTER="${5}"
MINION_IDENTIFIER="${6}"

if [ "${HOST}" = "" ] || [ "${USER_PASSWORD}" = "" ] || [ "${ROOT_PASSWORD}" = "" ] || [ "${PROXY}" = "" ] || [ "${MASTER}" = "" ] || [ "${MINION_IDENTIFIER}" = "" ]; then
    usage

    exit 1
fi

"${SCRIPT_DIRECTORY}"/bootstrap.tcl "${HOST}" "${USER_PASSWORD}" "${ROOT_PASSWORD}" "${PROXY}" "${MASTER}" "${MINION_IDENTIFIER}"
