#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} [--memory 2048][--disk-size 64] HOST_NAME"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
MEMORY=4096
DISK_SIZE=64

while true; do
    case ${1} in
        --memory)
            MEMORY=${2-}
            shift 2
            ;;
        --disk-size)
            DISK_SIZE=${2-}
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

OPTIND=1
HOST_NAME="${1}"

if [ "${HOST_NAME}" = "" ]; then
    usage

    exit 1
fi

touch "${SCRIPT_DIRECTORY}/../${HOST_NAME}.cfg"
chmod 600 "${SCRIPT_DIRECTORY}/../${HOST_NAME}.cfg"
DOMAIN=$(hostname -d)
ROOT_PASSWORD=$(pass "host/${HOST_NAME}.${DOMAIN}/root" 2>/dev/null || true)
USER_PASSWORD=$(pass "host/${HOST_NAME}.${DOMAIN}/${USER}" 2>/dev/null || true)

if [ "${ROOT_PASSWORD}" = "" ]; then
    ROOT_PASSWORD=$(pass generate "host/${HOST_NAME}.${DOMAIN}/root" --no-symbols 14)
fi

if [ "${USER_PASSWORD}" = "" ]; then
    USER_PASSWORD=$(pass generate "host/${HOST_NAME}.${DOMAIN}/${USER}" --no-symbols 14)
fi

FULL_NAME=$(getent passwd "${USER}" | cut -d : -f 5 | cut -d , -f 1)
dt --hostname "${HOST_NAME}" --domain "${DOMAIN}" --root-password "${ROOT_PASSWORD}" --user-name "${USER}" --user-password "${USER_PASSWORD}" --user-real-name "${FULL_NAME}" > "${SCRIPT_DIRECTORY}/../${HOST_NAME}.cfg"
"${SCRIPT_DIRECTORY}/create-new-machine.sh" --preseed-file "${SCRIPT_DIRECTORY}/../${HOST_NAME}.cfg" --network-device vboxnet0 --network-type hostonly --memory "${MEMORY}" --disk-size "${DISK_SIZE}" "${HOST_NAME}"
