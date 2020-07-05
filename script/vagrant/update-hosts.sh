#!/bin/sh -e

SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    SED='gsed'
    TEE='gtee'
else
    SED='sed'
    TEE='tee'
fi

HOST_NAME=$(cat tmp/hostname.txt)
DOMAIN=$(cat tmp/domain.txt)
ABSOLUTE_DOMAIN_NAME="${HOST_NAME}.${DOMAIN}"
RESULT=$(grep "${ABSOLUTE_DOMAIN_NAME}" /etc/hosts) || RESULT=''
ADDRESS=$(vagrant ssh --command /vagrant/script/vagrant/address.sh | tr -d '\r')

if [ "${RESULT}" = '' ]; then
    # shellcheck disable=SC1117
    printf "%s\t%s\n" "${ADDRESS}" "${ABSOLUTE_DOMAIN_NAME}" | sudo ${TEE} --append /etc/hosts >/dev/null
else
    ADDRESS_IN_FILE=$(echo "${RESULT}" | awk '{ print $1 }')

    if [ ! "${ADDRESS}" = "${ADDRESS_IN_FILE}" ]; then
        sudo ${SED} --in-place "s:${ADDRESS_IN_FILE}:${ADDRESS}:g" /etc/hosts
    fi
fi
