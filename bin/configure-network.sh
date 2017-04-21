#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} MACHINE_NAME ROOT_PASSWORD ADDRESS NETMASK NETWORK BROADCAST GATEWAY NAMESERVER SEARCH"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh

MACHINE_NAME="${1}"
ROOT_PASSWORD="${2}"
ADDRESS="${3}"
NETMASK="${4}"
NETWORK="${5}"
BROADCAST="${6}"
GATEWAY="${7}"
NAMESERVER="${8}"
SEARCH="${9}"

if [ "${MACHINE_NAME}" = "" ] || [ "${ROOT_PASSWORD}" = "" ] || [ "${ADDRESS}" = "" ] || [ "${NETMASK}" = "" ] || [ "${NETWORK}" = "" ] || [ "${BROADCAST}" = "" ] || [ "${GATEWAY}" = "" ] || [ "${NAMESERVER}" = "" ] || [ "${SEARCH}" = "" ]; then
    usage

    exit 1
fi

"${SCRIPT_DIRECTORY}"/input.sh "${MACHINE_NAME}" "root
"
sleep 1

"${SCRIPT_DIRECTORY}"/input.sh "${MACHINE_NAME}" "${ROOT_PASSWORD}
"
sleep 1

"${SCRIPT_DIRECTORY}"/input.sh "${MACHINE_NAME}" "sed -i s:dhcp:static: /etc/network/interfaces
echo 'address ${ADDRESS}' >> /etc/network/interfaces
echo 'netmask ${NETMASK}' >> /etc/network/interfaces
echo 'network ${NETWORK}' >> /etc/network/interfaces
echo 'broadcast ${BROADCAST}' >> /etc/network/interfaces
echo 'gateway ${GATEWAY}' >> /etc/network/interfaces
echo 'dns-nameservers ${NAMESERVER}' >> /etc/network/interfaces
echo 'dns-search ${SEARCH}' >> /etc/network/interfaces
reboot
"
