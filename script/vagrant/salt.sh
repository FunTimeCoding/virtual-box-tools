#!/bin/sh -e

MINION_IDENTIFIER="${1}"
CONFIGURATION_PATH="${2}"

if [ ! "${MINION_IDENTIFIER}" = '' ]; then
    mkdir -p /etc/salt/minion.d
    echo "${MINION_IDENTIFIER}" > /etc/salt/minion_id
fi

if [ ! "${CONFIGURATION_PATH}" = '' ]; then
    mkdir -p /etc/salt/minion.d
    cp "${CONFIGURATION_PATH}" /etc/salt/minion.d/minion.conf
fi

apt-get --quiet 2 install salt-minion
