#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} HOST USER_PASSWORD ROOT_PASSWORD MASTER MINION_IDENTIFIER [PROXY]"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh

HOST="${1}"
USER_PASSWORD="${2}"
ROOT_PASSWORD="${3}"
MASTER="${4}"
MINION_IDENTIFIER="${5}"
PROXY="${6}"

if [ "${HOST}" = "" ] || [ "${USER_PASSWORD}" = "" ] || [ "${ROOT_PASSWORD}" = "" ] || [ "${MASTER}" = "" ] || [ "${MINION_IDENTIFIER}" = "" ]; then
    usage

    exit 1
fi

if [ "${PROXY}" = "" ]; then
    "${SCRIPT_DIRECTORY}"/bootstrap-salt.tcl "${HOST}" "${USER_PASSWORD}" "${ROOT_PASSWORD}" "${MASTER}" "${MINION_IDENTIFIER}"
else
    "${SCRIPT_DIRECTORY}"/bootstrap-salt.tcl "${HOST}" "${USER_PASSWORD}" "${ROOT_PASSWORD}" "${MASTER}" "${MINION_IDENTIFIER}" "${PROXY}"
fi
