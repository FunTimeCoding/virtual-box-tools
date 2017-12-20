#!/bin/sh -e

HOST="${1}"

if [ "${HOST}" = "" ]; then
    echo "Usage: ${0} HOST"

    exit 1
fi

DOMAIN=$(hostname -d)
sqlite3 "${HOME}/.virtual-box-tools/user.sqlite" "SELECT password FROM user WHERE host_name = '${HOST}' AND user_name = '${USER}' AND domain_name = '${DOMAIN}'"

sqlite3 "${HOME}/.virtual-box-tools/user.sqlite" "SELECT password FROM user WHERE host_name = '${HOST}' AND user_name = 'root' AND domain_name = '${DOMAIN}'"
