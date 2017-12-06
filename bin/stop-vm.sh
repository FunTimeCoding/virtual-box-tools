#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} [--force][--wait] MACHINE_NAME"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
FORCE=false
WAIT=false

while true; do
    case ${1} in
        --force)
            FORCE=true
            shift
            ;;
        --wait)
            WAIT=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

MACHINE_NAME="${1}"

if [ "${MACHINE_NAME}" = "" ]; then
    usage

    exit 1
fi

if [ "${FORCE}" = true ]; then
    vbt host stop --name "${MACHINE_NAME}" --force
else
    if [ "${WAIT}" = true ]; then
        vbt host stop --name "${MACHINE_NAME}" --wait
    else
        vbt host stop --name "${MACHINE_NAME}"
    fi
fi
