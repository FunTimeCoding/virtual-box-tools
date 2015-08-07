#!/bin/sh -e

SCRIPT_DIR=$(cd "$(dirname "${0}")"; pwd)

usage(){
    echo "Usage: ${0} VM_NAME"
}

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

VALUE=$("${SCRIPT_DIR}/get-vm-mac.sh" "${1}")
LIST=$(echo "${VALUE}" | fold -w2)
RESULT=""

for HEX in ${LIST}; do
    RESULT="${RESULT}:${HEX}"
done

RESULT="${RESULT#:}"
echo "${RESULT}"
