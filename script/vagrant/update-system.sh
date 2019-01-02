#!/bin/sh -e

sed --in-place 's/deb.debian.org/ftp.de.debian.org/' /etc/apt/sources.list
export DEBIAN_FRONTEND=noninteractive
sudo apt-get --quiet 2 update
sudo apt-get --quiet 2 upgrade
sudo apt-get --quiet 2 dist-upgrade
