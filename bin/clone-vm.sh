#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} EXISTING_NAME NEW_NAME"
}

. "${SCRIPT_DIR}/../lib/virtual_box_tools.sh"
EXISTING_NAME="${1}"

if [ "${EXISTING_NAME}" = "" ]; then
    usage

    exit 1
fi

NEW_NAME="${2}"

if [ "${NEW_NAME}" = "" ]; then
    usage

    exit 1
fi

ERROR=false
OUTPUT=$(${MANAGE_COMMAND} clonevm "${EXISTING_NAME}" --name "${NEW_NAME}" --register 2>&1) || ERROR=true

if [ "${ERROR}" = true ]; then
    echo "Error:"
    echo "${OUTPUT}"

    exit 1
fi
