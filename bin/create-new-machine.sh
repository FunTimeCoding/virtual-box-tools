#!/bin/sh -e

if [ "$(command -v bc || true)" = "" ]; then
    echo "Command not found: bc"

    exit 1
fi

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
OPERATING_SYSTEM=$(uname)
DEBIAN_RELEASE=jessie
MEMORY_IN_MEGABYTE=256
DISK_SIZE_IN_GIGABYTE=16

if [ "${OPERATING_SYSTEM}" = Darwin ]; then
    NETWORK_DEVICE=en0
else
    NETWORK_DEVICE=eth0
fi

usage()
{
    echo "Usage: ${0} [--debian-release jessie|wheezy|squeeze][--network-device eth0][--network-type bridged|hostonly][--preseed-file FILE] MACHINE_NAME"
    echo "Debian device examples: eth0, eth1, en0, en1"
    echo "Defaults"
    echo "Release: ${DEBIAN_RELEASE}"
    echo "Device: ${NETWORK_DEVICE}"
    echo "Memory in megabyte: ${MEMORY_IN_MEGABYTE}"
    echo "Disk size in gigabyte: ${DISK_SIZE_IN_GIGABYTE}"
    echo "Leave --type unspecified to skip network configuration."
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh

while true; do
    case ${1} in
        --debian-release)
            DEBIAN_RELEASE=${2-}
            shift 2
            ;;
        --network-type)
            NETWORK_TYPE=${2-}
            shift 2
            ;;
        --network-device)
            NETWORK_DEVICE=${2-}
            shift 2
            ;;
        --preseed-file)
            PRESEED_FILE=${2-}
            shift 2
            ;;
        --memory)
            MEMORY_IN_MEGABYTE=${2-}
            shift 2
            ;;
        --disk-size)
            DISK_SIZE_IN_GIGABYTE=${2-}
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

if [ "${SUDO_USER}" = "" ]; then
    HOME_DIRECTORY="${HOME}"
else
    HOME_DIRECTORY="/home/${SUDO_USER}"
fi

${VBOXMANAGE} createvm --name "${MACHINE_NAME}" --register --ostype Debian_64
CONTROLLER_NAME="SATA Controller"
${VBOXMANAGE} storagectl "${MACHINE_NAME}" --name "${CONTROLLER_NAME}" --add sata
DISK_NAME="${MACHINE_NAME}.vdi"
MACHINE_DIRECTORY="${HOME_DIRECTORY}/VirtualBox VMs/${MACHINE_NAME}"
DISK_PATH="${MACHINE_DIRECTORY}/${DISK_NAME}"
DISK_SIZE_IN_MEGABYTE=$(echo "${DISK_SIZE_IN_GIGABYTE} * 1024" | bc)
${VBOXMANAGE} createmedium disk --filename "${DISK_PATH}" --size "${DISK_SIZE_IN_MEGABYTE}"
${VBOXMANAGE} storageattach "${MACHINE_NAME}" --storagectl "${CONTROLLER_NAME}" --port 0 --device 0 --type hdd --medium "${DISK_PATH}"
${VBOXMANAGE} storageattach "${MACHINE_NAME}" --storagectl "${CONTROLLER_NAME}" --port 1 --device 0 --type dvddrive --medium emptydrive
${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --acpi on --memory "${MEMORY_IN_MEGABYTE}" --vram 16

if [ "${PRESEED_FILE}" = "" ]; then
    ${VBOXMANAGE} startvm "${MACHINE_NAME}"

    exit 0
fi

NETWORK_BOOT_ARCHIVE="${HOME}/tmp/netboot-${DEBIAN_RELEASE}.tar.gz"

if [ ! -f "${NETWORK_BOOT_ARCHIVE}" ]; then
    mkdir -p "${HOME}/tmp"
    wget --output-document "${NETWORK_BOOT_ARCHIVE}" "http://ftp.debian.org/debian/dists/${DEBIAN_RELEASE}/main/installer-amd64/current/images/netboot/netboot.tar.gz"
fi

TRIVIAL_DIRECTORY="${HOME}/tmp/trivial"
CPIO_ROOT_DIRECTORY="${TRIVIAL_DIRECTORY}/cpio"
sudo rm -rf "${TRIVIAL_DIRECTORY}"
mkdir -p "${CPIO_ROOT_DIRECTORY}"
tar xf "${NETWORK_BOOT_ARCHIVE}" --directory "${TRIVIAL_DIRECTORY}"
cp "${PRESEED_FILE}" "${CPIO_ROOT_DIRECTORY}/preseed.cfg"

if [ "${OPERATING_SYSTEM}" = Darwin ]; then
    sudo chown root:wheel "${CPIO_ROOT_DIRECTORY}/preseed.cfg"
else
    sudo chown root:root "${CPIO_ROOT_DIRECTORY}/preseed.cfg"
fi

cd "${CPIO_ROOT_DIRECTORY}"
gzip -d < "${TRIVIAL_DIRECTORY}/debian-installer/amd64/initrd.gz" | sudo cpio -i
find . | sudo cpio -o --format=newc | gzip -9c > "${TRIVIAL_DIRECTORY}/debian-installer/amd64/initrd.gz"
sudo rm -rf "${CPIO_ROOT_DIRECTORY}"
cd "${TRIVIAL_DIRECTORY}"
ln -s debian-installer/amd64/pxelinux.0 debian.pxe
echo "DEFAULT ${DEBIAN_RELEASE}
LABEL ${DEBIAN_RELEASE}
kernel debian-installer/amd64/linux
append auto initrd=debian-installer/amd64/initrd.gz priority=critical preseed/file=/preseed.cfg" >> "${TRIVIAL_DIRECTORY}/debian-installer/amd64/boot-screens/syslinux.cfg"

if [ "${OPERATING_SYSTEM}" = Darwin ]; then
    VIRTUAL_BOX_DIRECTORY="${HOME_DIRECTORY}/Library/VirtualBox"
else
    VIRTUAL_BOX_DIRECTORY="${HOME_DIRECTORY}/.config/VirtualBox"
fi

sudo rm -rf "${VIRTUAL_BOX_DIRECTORY}/TFTP"
sudo mv "${TRIVIAL_DIRECTORY}" "${VIRTUAL_BOX_DIRECTORY}/TFTP"

if [ ! "${SUDO_USER}" = "" ]; then
    sudo chown -R "${SUDO_USER}:${SUDO_USER}" "${VIRTUAL_BOX_DIRECTORY}/TFTP"
fi

${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --nic1 nat --nictype1 virtio
${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --boot1 net --nattftpfile1 /debian.pxe
${VBOXMANAGE} startvm "${MACHINE_NAME}" --type headless
echo "Install operating system. The virtual machine will shut down for post configuration afterwards."

for MINUTE in $(seq 1 30); do
    echo "${MINUTE}"
    sleep 60
    STATE=$("${SCRIPT_DIRECTORY}"/get-vm-state.sh "${MACHINE_NAME}")

    if [ "${STATE}" = poweroff ]; then
        break
    fi
done

${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --boot1 disk

if [ "${NETWORK_TYPE}" = hostonly ]; then
    ${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --nic1 hostonly --hostonlyadapter1 "${NETWORK_DEVICE}"
elif [ "${NETWORK_TYPE}" = bridged ]; then
    ${VBOXMANAGE} modifyvm "${MACHINE_NAME}" --nic1 bridged --bridgeadapter1 "${NETWORK_DEVICE}"
fi
