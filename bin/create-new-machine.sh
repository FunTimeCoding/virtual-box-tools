#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
OPERATING_SYSTEM=$(uname)
DEBIAN_RELEASE=jessie

if [ "${OPERATING_SYSTEM}" = Linux ]; then
    NETWORK_DEVICE=eth0
elif [ "${OPERATING_SYSTEM}" = Darwin ]; then
    NETWORK_DEVICE=en0
fi

usage()
{
    echo "Usage: ${0} [--release DEBIAN_RELEASE] [--device eth0] [--preseed PRESEED_FILE] MACHINE_NAME"
    echo "Debian release can be jessie, wheezy, squeeze."
    echo "Default release: ${DEBIAN_RELEASE}"
    echo "Debian device examples: eth0, eth1, en0, en1"
    echo "Default device: ${NETWORK_DEVICE}"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh

while true; do
    case ${1} in
        --release)
            DEBIAN_RELEASE=${2-}
            shift 2
            ;;
        --device)
            NETWORK_DEVICE=${2-}
            shift 2
            ;;
        --preseed)
            PRESEED_FILE=${2-}
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

vboxmanage createvm --name "${MACHINE_NAME}" --register --ostype Debian_64
CONTROLLER_NAME="SATA Controller"
vboxmanage storagectl "${MACHINE_NAME}" --name "${CONTROLLER_NAME}" --add sata
DISK_NAME="${MACHINE_NAME}.vdi"
MACHINE_DIRECTORY="${HOME}/VirtualBox VMs/${MACHINE_NAME}"
DISK_PATH="${MACHINE_DIRECTORY}/${DISK_NAME}"
vboxmanage createmedium disk --filename "${DISK_PATH}" --size 16384
vboxmanage storageattach "${MACHINE_NAME}" --storagectl "${CONTROLLER_NAME}" --port 0 --device 0 --type hdd --medium "${DISK_PATH}"
vboxmanage storageattach "${MACHINE_NAME}" --storagectl "${CONTROLLER_NAME}" --port 1 --device 0 --type dvddrive --medium emptydrive
vboxmanage modifyvm "${MACHINE_NAME}" --acpi on --memory 256 --vram 16

if [ "${PRESEED_FILE}" = "" ]; then
    vboxmanage startvm "${MACHINE_NAME}"

    exit 0
fi

if [ "${OPERATING_SYSTEM}" = Darwin ]; then
    TRIVIAL_DIRECTORY="${HOME}/Library/VirtualBox/TFTP"
else
    TRIVIAL_DIRECTORY="${HOME}/.config/VirtualBox/TFTP"
fi

sudo rm -rf "${TRIVIAL_DIRECTORY:?}"
mkdir "${TRIVIAL_DIRECTORY}"
cp "${PRESEED_FILE}" "${TRIVIAL_DIRECTORY}/preseed.cfg"
cd "${TRIVIAL_DIRECTORY}"
NETWORK_BOOT_ARCHIVE="${HOME}/tmp/netboot-${DEBIAN_RELEASE}.tar.gz"

if [ ! -f "${NETWORK_BOOT_ARCHIVE}" ]; then
    wget --output-document "${NETWORK_BOOT_ARCHIVE}" "http://ftp.debian.org/debian/dists/${DEBIAN_RELEASE}/main/installer-amd64/current/images/netboot/netboot.tar.gz"
fi

tar xf "${NETWORK_BOOT_ARCHIVE}" --directory "${TRIVIAL_DIRECTORY}"
mkdir tmp
(
cd tmp
gzip -d < ../debian-installer/amd64/initrd.gz | sudo cpio -i
sudo cp ../preseed.cfg .

if [ "${OPERATING_SYSTEM}" = Darwin ]; then
    sudo chown root:wheel preseed.cfg
else
    sudo chown root:root preseed.cfg
fi

find . | cpio -o --format=newc | gzip -9c > ../initrd.gz
)
cp initrd.gz debian-installer/amd64
ln -s debian-installer/amd64/pxelinux.0 debian.pxe
echo "DEFAULT ${DEBIAN_RELEASE}
LABEL ${DEBIAN_RELEASE}
kernel debian-installer/amd64/linux
append auto initrd=debian-installer/amd64/initrd.gz priority=critical preseed/file=/preseed.cfg" >> debian-installer/amd64/boot-screens/syslinux.cfg
vboxmanage modifyvm "${MACHINE_NAME}" --boot1 net --nattftpfile1 /debian.pxe
vboxmanage startvm "${MACHINE_NAME}" --type headless

for MINUTE in $(seq 1 30); do
    echo "${MINUTE}"
    sleep 60
    STATE=$("${SCRIPT_DIRECTORY}"/get-vm-state.sh "${MACHINE_NAME}")

    if [ "${STATE}" = poweroff ]; then
        break
    fi
done

vboxmanage modifyvm "${MACHINE_NAME}" --boot1 disk --nic1 bridged --bridgeadapter1 "${NETWORK_DEVICE}"
