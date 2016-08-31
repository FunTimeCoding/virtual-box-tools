#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} MACHINE_NAME [enable|disable]"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
MACHINE_NAME="${1}"

if [ "${MACHINE_NAME}" = "" ]; then
    usage

    exit 1
fi

OUTPUT=$(${VBOXMANAGE} list systemproperties | grep Autostart)
ACTUAL=$(echo "${OUTPUT#*path:}" | xargs)
KEY=autostartdbpath
EXPECTED=/etc/vbox

if [ ! "${ACTUAL}" = "${EXPECTED}" ]; then
    echo "Setting ${KEY} incorrect '${ACTUAL}'."
    echo "Update to new value '${EXPECTED}'."
    ${VBOXMANAGE} setproperty "${KEY}" "${EXPECTED}"
    echo "Done."
fi

if [ ! "${SUDO_USER}" = "" ]; then
    sudo chown "${SUDO_USER}" "${EXPECTED}"
fi

NEW_STATE="${2}"

if [ "${NEW_STATE}" = "" ]; then
    OUTPUT=$(${VBOXMANAGE} showvminfo "${MACHINE_NAME}" --details --machinereadable | grep autostart-enabled)
    VALUE=$(echo "${OUTPUT#*autostart-enabled=}" | xargs)
    echo "${VALUE}"
else
    if [ "${NEW_STATE}" = enable ]; then
        ${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --autostart-enabled on
    elif [ "${NEW_STATE}" = disable ]; then
        ${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --autostart-enabled off
    else
        echo "Unknown state: ${NEW_STATE}"

        exit 1
    fi
fi
