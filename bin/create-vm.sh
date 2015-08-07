#!/bin/sh -e

SCRIPT_DIR=$(cd "$(dirname "${0}")"; pwd)

usage(){
    echo "Usage: ${0} [--help][--wait][--verbose] NAME"
}

WAIT=false

while true; do
    case ${1} in
        --wait)
            WAIT=true
            shift
            ;;
        --help)
            usage

            exit 0
            ;;
        --verbose)
            set -x
            shift
            ;;
        *)
            break
            ;;
    esac
done

if [ "${1}" = "" ]; then
    usage

    exit 1
fi

NAME="${1}"

"${SCRIPT_DIR}/clone-vm.sh" jessie "${NAME}"
"${SCRIPT_DIR}/start-vm.sh" "${NAME}"

if [ "${WAIT}" = "true" ]; then
    echo "Wait for VM to finish booting."
    BOOT_TIME="0"

    for SECOND in $(seq 1 60); do
        sleep 1
        IP=$("${SCRIPT_DIR}/get-vm-ip.sh" "${NAME}")

        if [ ! "${IP}" = "" ]; then

            BOOT_TIME="${SECOND}"
            break
        fi
    done

    MAC=$("${SCRIPT_DIR}/get-vm-mac.sh" --colons "${NAME}")
    echo "BOOT_TIME: ${BOOT_TIME}"
    echo "IP: ${IP}"
    echo "MAC: ${MAC}"
else
    echo "VM is booting."
fi
