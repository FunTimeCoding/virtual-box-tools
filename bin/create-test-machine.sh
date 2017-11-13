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

# TODO: Creation time is not stored in the file system. Periodically delete it.
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
pushd "${HOME}/src/qemu-tools/tmp/web"
nohup python3 -m http.server &
WEB_SERVER="${!}"

clean_up()
{
    kill "${WEB_SERVER}" || true
    remove_machine
}

trap clean_up EXIT
popd
vboxmanage startvm example
sleep 30
vboxmanage controlvm example keyboardputscancode 01 81
bin/input.sh example "auto url=http://${ADDRESS}:8000/preseed.cfg"
# TODO: Use input.sh to send \n.
vboxmanage controlvm example keyboardputscancode 1c 9c
sleep 600
vboxmanage modifyvm example --boot1 disk
vboxmanage modifyvm example --nic1 hostonly --hostonlyadapter1 vboxnet0
