#!/bin/sh -e

remove_machine()
{
    bin/stop-vm.sh --force example || true
    sleep 1
    # TODO: Fix order of arguments.
    bin/delete-vm.sh example --yes || true
    sleep 1
}

remove_machine
ADDRESS="${1}"

if [ "${ADDRESS}" = "" ]; then
    echo "Usage: ${0} ADDRESS"

    exit 1
fi

vboxmanage createvm --name example --register --ostype Debian_64
vboxmanage storagectl example --name "SATA controller" --add sata
vboxmanage createmedium disk --filename tmp/example.vdi --size 4096
vboxmanage storageattach example --storagectl "SATA controller" --port 0 --device 0 --type hdd --medium tmp/example.vdi
vboxmanage storageattach example --storagectl "SATA controller" --port 1 --device 0 --type dvddrive --medium emptydrive
vboxmanage modifyvm example --acpi on --cpus 1 --memory 1024 --vram 16
SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    STAT=gstat
    DATE=gdate
else
    STAT=stat
    DATE=date
fi

if [ -f tmp/netboot.tar.gz ] ;then
    MODIFIED=$(${STAT} --format=%Y tmp/netboot.tar.gz)
    ONE_HOUR_AGO=$(${DATE} -d "-1 hour" +%s)

    if [ "${MODIFIED}" -lt "${ONE_HOUR_AGO}" ]; then
        rm tmp/netboot.tar.gz
    fi
fi

if [ ! -f tmp/netboot.tar.gz ]; then
    wget --output-document tmp/netboot.tar.gz http://ftp.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/netboot.tar.gz
fi

if [ "${SYSTEM}" = Darwin ]; then
    DIRECTORY="${HOME}/Library/VirtualBox"
else
    DIRECTORY="${HOME}/.config/VirtualBox"
fi

rm -rf "${DIRECTORY}/TFTP"
mkdir -p "${DIRECTORY}/TFTP"

if [ ! -d "${DIRECTORY}/TFTP/debian-installer" ]; then
    tar --extract --file tmp/netboot.tar.gz --directory "${DIRECTORY}/TFTP"
fi

vboxmanage modifyvm example --nic1 nat --boot1 net --nattftpfile1 /pxelinux.0

# TODO: Generate config and move to a directory in this project.
#pushd "${HOME}/src/qemu-tools/tmp/web"
#nohup python3 -m http.server &
#WEB_SERVER="${!}"

kill_web_server()
{
    #kill "${WEB_SERVER}" || true
    remove_machine
}

trap kill_web_server EXIT

#popd

vboxmanage startvm example

#sleep 30

echo "Press enter to continue once the machine is waiting for input."
read -r READ
vboxmanage controlvm example keyboardputscancode 01 81
# Install requires more additional arguments. Auto is more simple.
#bin/input.sh example "install "
#bin/input.sh example preseed/url=http://${ADDRESS}:8000/preseed.cfg
bin/input.sh example "auto url=http://${ADDRESS}:8000/web/preseed.cfg"

# TODO: Why is the installer stuck?
#bin/input.sh example "install "
#bin/input.sh example "preseed/url=http://${ADDRESS}:8000/preseed.cfg "
#bin/input.sh example "debian-installer=en_US auto locale=en_US "
#bin/input.sh example "kbd-chooser/method=us "
#bin/input.sh example "netcfg/get_hostname=example "
#bin/input.sh example "netcfg/get_domain=example.org fb=false "
#bin/input.sh example "debconf/frontend=noninteractive "
#bin/input.sh example "console-setup/ask_detect=false "
#bin/input.sh example "console-keymaps-at/keymap=us "
#bin/input.sh example "keyboard-configuration/xkb-keymap=us"

# TODO: Fix send \n.
#bin/input.sh example "\n"
vboxmanage controlvm example keyboardputscancode 1c 9c
#sleep 600

echo "Press enter to continue once the machine is shut down."
read -r READ
#vboxmanage modifyvm example --boot1 disk
#vboxmanage modifyvm example --nic1 hostonly --hostonlyadapter1 vboxnet0
