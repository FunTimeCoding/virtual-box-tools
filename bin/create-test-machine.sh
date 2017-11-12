#!/bin/sh -e

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

if [ ! -f tmp/netboot.tar.gz ]; then
    wget --output-document tmp/netboot.tar.gz http://ftp.debian.org/debian/dists/stretch/main/installer-amd64/current/images/netboot/netboot.tar.gz
fi

SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    CONFIG_DIRECTORY="${HOME}/Library/VirtualBox"
else
    CONFIG_DIRECTORY="${HOME}/.config/VirtualBox"
fi

mkdir -p "${CONFIG_DIRECTORY}/TFTP"

if [ ! -d "${CONFIG_DIRECTORY}/TFTP/debian-installer" ]; then
    tar --extract --file tmp/netboot.tar.gz --directory "${CONFIG_DIRECTORY}/TFTP"
fi

vboxmanage modifyvm example --nic1 nat --boot1 net --nattftpfile1 /pxelinux.0

pushd ~/src/qemu-tools/tmp/web
nohup python3 -m http.server &
WEB_SERVER="${!}"
popd

vboxmanage startvm example
sleep 30
vboxmanage controlvm example keyboardputscancode 01 81
# Install requires more additional arguments. Auto is more simple.
#bin/input.sh example "install "
#bin/input.sh example preseed/url=http://${ADDRESS}:8000/preseed.cfg
bin/input.sh example "auto url=http://${ADDRESS}:8000/preseed.cfg"
vboxmanage controlvm example keyboardputscancode 1c 9c
sleep 600
vboxmanage modifyvm example --boot1 disk
vboxmanage modifyvm example --nic1 hostonly --hostonlyadapter1 vboxnet0

kill "${WEB_SERVER}"
