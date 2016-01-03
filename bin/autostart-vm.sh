#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} VM_NAME [enable|disable]"
}

. "${SCRIPT_DIR}/../lib/virtual_box_tools.sh"
VM_NAME="${1}"

if [ "${VM_NAME}" = "" ]; then
    usage

    exit 1
fi

OUTPUT=$(${MANAGE_COMMAND} list systemproperties | grep Autostart)
ACTUAL=$(echo ${OUTPUT#*path:} | xargs)
KEY="autostartdbpath"
EXPECTED="/etc/vbox"

if [ ! "${ACTUAL}" = "${EXPECTED}" ]; then
    echo "Setting ${KEY} incorrect '${ACTUAL}'."
    echo "Update to new value '${EXPECTED}'."
    ${MANAGE_COMMAND} setproperty "${KEY}" "${EXPECTED}"
    echo "Done."
fi

NEW_STATE="${2}"

if [ "${NEW_STATE}" = "" ]; then
    OUTPUT=$(${MANAGE_COMMAND} showvminfo "${VM_NAME}" --details --machinereadable | grep "autostart-enabled")
    VALUE=$(echo ${OUTPUT#*autostart-enabled=} | xargs)
    echo "${VALUE}"
else
    if [ "${NEW_STATE}" = "enable" ]; then
        ${MANAGE_COMMAND} modifyvm ${VM_NAME} --autostart-enabled on
    elif [ "${NEW_STATE}" = "disable" ]; then
        ${MANAGE_COMMAND} modifyvm ${VM_NAME} --autostart-enabled off
    else
        echo "Unknown state: ${NEW_STATE}"

        exit 1
    fi
fi
