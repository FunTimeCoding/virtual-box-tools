#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
SYSTEM=$(uname)
CORES=1
MEMORY_IN_MEGABYTES=4096
DISK_SIZE_IN_GIGABYTES=64
BRIDGE_DEVICE=""

usage()
{
    echo "Usage: ${0} [--cores NUMBER][--memory NUMBER][--disk-size NUMBER][--bridge-device BRIDGE_DEVICE] MACHINE_NAME"
    echo "Leave --network-type unspecified to skip network configuration."
    echo "If bridge device is not defined, the machine will be connected to the host only network vboxnet0."
    echo "Defaults:"
    echo "Cores: ${CORES}"
    echo "Memory in megabytes: ${MEMORY_IN_MEGABYTES}"
    echo "Disk size in gigabytes: ${DISK_SIZE_IN_GIGABYTES}"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh

while true; do
    case ${1} in
        --cores)
            CORES=${2-}
            shift 2
            ;;
        --memory)
            MEMORY_IN_MEGABYTES=${2-}
            shift 2
            ;;
        --disk-size)
            DISK_SIZE_IN_GIGABYTES=${2-}
            shift 2
            ;;
        --bridge-device)
            BRIDGE_DEVICE=${2-}
            shift 2
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

${VBOXMANAGE} createvm --name "${MACHINE_NAME}" --register --ostype Debian_64
CONTROLLER_NAME="SATA Controller"
${VBOXMANAGE} storagectl "${MACHINE_NAME}" --name "${CONTROLLER_NAME}" --add sata
DISK_NAME="${MACHINE_NAME}.vdi"

if [ "${SUDO_USER}" = "" ]; then
    HOME_DIRECTORY="${HOME}"
else
    HOME_DIRECTORY="/home/${SUDO_USER}"
fi

DISK_PATH="${HOME_DIRECTORY}/VirtualBox VMs/${MACHINE_NAME}/${DISK_NAME}"
DISK_SIZE_IN_MEGABYTES=$(echo "${DISK_SIZE_IN_GIGABYTES} * 1024" | bc)
${VBOXMANAGE} createmedium disk --filename "${DISK_PATH}" --size "${DISK_SIZE_IN_MEGABYTES}"
${VBOXMANAGE} storageattach "${MACHINE_NAME}" --storagectl "${CONTROLLER_NAME}" --port 0 --device 0 --type hdd --medium "${DISK_PATH}"
${VBOXMANAGE} storageattach "${MACHINE_NAME}" --storagectl "${CONTROLLER_NAME}" --port 1 --device 0 --type dvddrive --medium emptydrive
${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --acpi on --cpus "${CORES}" --memory "${MEMORY_IN_MEGABYTES}" --vram 16
mkdir -p "${SCRIPT_DIRECTORY}/../tmp/web"

if [ ! -f "${SCRIPT_DIRECTORY}/../tmp/netboot.tar.gz" ]; then
    wget --output-document "${SCRIPT_DIRECTORY}/../tmp/netboot.tar.gz" http://ftp.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/netboot.tar.gz
fi

SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    CONFIGURATION_DIRECTORY="${HOME_DIRECTORY}/Library/VirtualBox"
else
    CONFIGURATION_DIRECTORY="${HOME_DIRECTORY}/.config/VirtualBox"
fi

if [ "${SUDO_USER}" = "" ]; then
    rm -rf "${CONFIGURATION_DIRECTORY}/TFTP"
    mkdir -p "${CONFIGURATION_DIRECTORY}/TFTP"

    if [ ! -d "${CONFIGURATION_DIRECTORY}/TFTP/debian-installer" ]; then
        tar --extract --file "${SCRIPT_DIRECTORY}/../tmp/netboot.tar.gz" --directory "${CONFIGURATION_DIRECTORY}/TFTP"
    fi
else
    ${SUDO} rm -rf "${CONFIGURATION_DIRECTORY}/TFTP"
    ${SUDO} mkdir -p "${CONFIGURATION_DIRECTORY}/TFTP"

    if [ ! -d "${CONFIGURATION_DIRECTORY}/TFTP/debian-installer" ]; then
        ${SUDO} tar --extract --file "${SCRIPT_DIRECTORY}/../tmp/netboot.tar.gz" --directory "${CONFIGURATION_DIRECTORY}/TFTP"
    fi
fi

${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --nic1 nat --boot1 net --nattftpfile1 /pxelinux.0
cd "${SCRIPT_DIRECTORY}/../tmp/web"
nohup python3 -m http.server &
WEB_SERVER="${!}"

clean_up()
{
    kill "${WEB_SERVER}" || true
}

trap clean_up EXIT INT
${VBOXMANAGE} startvm "${MACHINE_NAME}" --type headless
sleep 20
# TODO: Use input.sh to send escape.
${VBOXMANAGE} controlvm "${MACHINE_NAME}" keyboardputscancode 01 81
sleep 1
"${SCRIPT_DIRECTORY}/input.sh" "${MACHINE_NAME}" "auto url=http://${ADDRESS}:8000/${MACHINE_NAME}.cfg"
sleep 1
# TODO: Use input.sh to send return (\n).
${VBOXMANAGE} controlvm "${MACHINE_NAME}" keyboardputscancode 1c 9c
echo

for MINUTE in $(seq 1 45); do
    echo -n .
    sleep 60
    STATE=$("${SCRIPT_DIRECTORY}/get-vm-state.sh" "${MACHINE_NAME}")

    if [ "${STATE}" = poweroff ]; then
        break
    fi
done

${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --boot1 disk

if [ "${BRIDGE_DEVICE}" = "" ]; then
    ${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --nic1 hostonly --hostonlyadapter1 vboxnet0
else
    ${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --nic1 bridged --bridgeadapter1 "${BRIDGE_DEVICE}"
fi
