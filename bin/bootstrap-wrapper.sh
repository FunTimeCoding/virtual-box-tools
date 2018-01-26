#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} HOST [PUBLIC_KEY_PATH]"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh

HOST_NAME="${1}"
PUBLIC_KEY_PATH="${2}"

if [ "${HOST_NAME}" = "" ]; then
    usage

    exit 1
fi

if [ "${PUBLIC_KEY_PATH}" = "" ]; then
    PUBLIC_KEY_PATH="${HOME}/.ssh/id_rsa.pub"
fi

USER_NAME=$(sqlite3 "${HOME}/.virtual-box-tools/user.sqlite" "SELECT user_name FROM user WHERE host_name = '${HOST_NAME}' AND user_name != 'root'")
DOMAIN=$(sqlite3 "${HOME}/.virtual-box-tools/user.sqlite" "SELECT domain_name FROM user WHERE host_name = '${HOST_NAME}' AND user_name = 'root'")
USER_PASSWORD=$(sqlite3 "${HOME}/.virtual-box-tools/user.sqlite" "SELECT password FROM user WHERE host_name = '${HOST_NAME}' AND user_name = '${USER_NAME}'")
ROOT_PASSWORD=$(sqlite3 "${HOME}/.virtual-box-tools/user.sqlite" "SELECT password FROM user WHERE host_name = '${HOST_NAME}' AND user_name = 'root'")
PUBLIC_KEY=$(cat "${PUBLIC_KEY_PATH}")
"${SCRIPT_DIRECTORY}"/bootstrap.tcl "${HOST_NAME}" "${USER_PASSWORD}" "${ROOT_PASSWORD}" "${PUBLIC_KEY}"
