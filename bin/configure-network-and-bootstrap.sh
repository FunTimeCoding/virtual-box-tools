#!/bin/sh -e

HOST_NAME="${1}"
NETMASK="${2}"
NETWORK="${3}"
BROADCAST="${4}"
GATEWAY="${5}"
NAMESERVER="${6}"
PUBLIC_KEY_PATH="${7}"

if [ "${HOST_NAME}" = "" ] || [ "${NETMASK}" = "" ] || [ "${NETWORK}" = "" ] || [ "${BROADCAST}" = "" ] || [ "${GATEWAY}" = "" ] || [ "${NAMESERVER}" = "" ] || [ "${PUBLIC_KEY_PATH}" = "" ]; then
    echo "Usage: ${0} HOST_NAME DOMAIN NETMASK NETWORK BROADCAST GATEWAY NAMESERVER SEARCH_DOMAIN PUBLIC_KEY_PATH"

    exit 1
fi

# TODO: Check if virtual machine is running.
#vbt host start --name "${HOST_NAME}"
#sleep 60

USER_NAME=$(sqlite3 "${HOME}/.virtual-box-tools/user.sqlite" "SELECT user_name FROM user WHERE host_name = '${HOST_NAME}' AND user_name != 'root'")
DOMAIN=$(sqlite3 "${HOME}/.virtual-box-tools/user.sqlite" "SELECT domain_name FROM user WHERE host_name = '${HOST_NAME}' AND user_name = 'root'")
USER_PASSWORD=$(sqlite3 "${HOME}/.virtual-box-tools/user.sqlite" "SELECT password FROM user WHERE host_name = '${HOST_NAME}' AND user_name = '${USER_NAME}'")
ROOT_PASSWORD=$(sqlite3 "${HOME}/.virtual-box-tools/user.sqlite" "SELECT password FROM user WHERE host_name = '${HOST_NAME}' AND user_name = 'root'")
ADDRESS=$(dig +noall +answer "${HOST_NAME}.${DOMAIN}" | grep "${HOST_NAME}.${DOMAIN}" | awk '{ print $5 }')
#bin/configure-network.sh "${HOST_NAME}" "${ROOT_PASSWORD}" "${ADDRESS}" "${NETMASK}" "${NETWORK}" "${BROADCAST}" "${GATEWAY}" "${NAMESERVER}" "${DOMAIN}"
#vbt host stop --name "${HOST_NAME}"
#sleep 30
#vbt host start --name "${HOST_NAME}"
#sleep 120
sh -ex bin/bootstrap-wrapper.sh "${USER_NAME}@${HOST_NAME}.${DOMAIN}" "${PUBLIC_KEY_PATH}"
#PROXY=""
#SALT_MASTER=""
#MINION_IDENTIFIER=""
#bin/bootstrap-wrapper-salt.sh "${USER_NAME}@${HOST_NAME}.${DOMAIN}" "${USER_PASSWORD}" "${ROOT_PASSWORD}" "${SALT_MASTER}" "${MINION_IDENTIFIER}" "${PROXY}"
