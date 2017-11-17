#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} MACHINE_NAME [enable|disable]"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh

ADDRESS="${1}"

if [ "${ADDRESS}" = "" ]; then
    echo "Usage: ${0} ADDRESS"

    exit 1
fi

remove_machine()
{
    bin/stop-vm.sh --force example || true
    sleep 1
    # TODO: Fix order of arguments.
    bin/delete-vm.sh example --yes || true
    sleep 1
}

remove_machine

if [ "${SUDO_USER}" = "" ]; then
    HOME_DIRECTORY="${HOME}"
else
    HOME_DIRECTORY="/home/${SUDO_USER}"
fi

${VBOXMANAGE} createvm --name example --register --ostype Debian_64
${VBOXMANAGE} storagectl example --name "SATA controller" --add sata
${VBOXMANAGE} createmedium disk --filename "${HOME_DIRECTORY}/VirtualBox VMs/example/example.vdi" --size 4096
${VBOXMANAGE} storageattach example --storagectl "SATA controller" --port 0 --device 0 --type hdd --medium "${HOME_DIRECTORY}/VirtualBox VMs/example/example.vdi"
${VBOXMANAGE} storageattach example --storagectl "SATA controller" --port 1 --device 0 --type dvddrive --medium emptydrive
${VBOXMANAGE} modifyvm example --acpi on --cpus 1 --memory 1024 --vram 16

# TODO: Creation time is not stored in the file system. Periodically delete it.
if [ ! -f tmp/netboot.tar.gz ]; then
    wget --output-document tmp/netboot.tar.gz http://ftp.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/netboot.tar.gz
fi

SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    DIRECTORY="${HOME_DIRECTORY}/Library/VirtualBox"
else
    DIRECTORY="${HOME_DIRECTORY}/.config/VirtualBox"
fi

if [ "${SUDO_USER}" = "" ]; then
    rm -rf "${DIRECTORY}/TFTP"
    mkdir -p "${DIRECTORY}/TFTP"

    if [ ! -d "${DIRECTORY}/TFTP/debian-installer" ]; then
        tar --extract --file tmp/netboot.tar.gz --directory "${DIRECTORY}/TFTP"
    fi
else
    sudo -u "${SUDO_USER}" rm -rf "${DIRECTORY}/TFTP"
    sudo -u "${SUDO_USER}" mkdir -p "${DIRECTORY}/TFTP"

    if [ ! -d "${DIRECTORY}/TFTP/debian-installer" ]; then
        sudo -u "${SUDO_USER}" tar --extract --file tmp/netboot.tar.gz --directory "${DIRECTORY}/TFTP"
    fi
fi

${VBOXMANAGE} modifyvm example --nic1 nat --boot1 net --nattftpfile1 /pxelinux.0
DOMAIN=$(hostname)
mkdir -p tmp/web
"${HOME}/src/debian-tools/.venv/bin/dt" --hostname example --domain shiin.org --root-password root --user-name example --user-password example --user-real-name "Example User" --release stretch --output-document tmp/web/example.cfg
cd tmp/web
nohup python3 -m http.server &
WEB_SERVER="${!}"

clean_up()
{
    kill "${WEB_SERVER}" || true
    # Machine should stay after build is done.
    #remove_machine
}

trap clean_up EXIT
cd ../..
${VBOXMANAGE} startvm example --type headless
sleep 30
${VBOXMANAGE} controlvm example keyboardputscancode 01 81
bin/input.sh example "auto url=http://${ADDRESS}:8000/preseed.cfg"
# TODO: Use input.sh to send \n.
${VBOXMANAGE} controlvm example keyboardputscancode 1c 9c
sleep 600
${VBOXMANAGE} modifyvm example --boot1 disk
${VBOXMANAGE} modifyvm example --nic1 hostonly --hostonlyadapter1 vboxnet0
