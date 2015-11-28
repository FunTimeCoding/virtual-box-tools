#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} [--force][--wait] VM_NAME"
}

. "${SCRIPT_DIR}/../lib/virtual_box_tools.sh"
FORCE=false
WAIT=false

while true; do
    case ${1} in
        -f|--force)
            FORCE=true
            shift
            ;;
        -w|--wait)
            WAIT=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

VM_NAME="${1}"

if [ "${VM_NAME}" = "" ]; then
    usage

    exit 1
fi

if [ "${FORCE}" = true ]; then
    echo "Force shutdown."
    ${MANAGE_COMMAND} controlvm "${VM_NAME}" poweroff
else
    echo "Stop running VM."
    ${MANAGE_COMMAND} controlvm "${VM_NAME}" acpipowerbutton
fi

if [ "${WAIT}" = true ]; then
    for SECOND in $(seq 1 30); do
        echo "${SECOND}"
        sleep 1
        STATE=$("${SCRIPT_DIR}"/get-vm-state.sh "${VM_NAME}")

        if [ "${STATE}" = "poweroff" ]; then
            DOWN=true

            break
        fi
    done

    if [ "${DOWN}" = "false" ]; then
        echo "Error: VM could not be shut down."
    fi
fi
