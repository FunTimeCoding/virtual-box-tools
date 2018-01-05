#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive
sudo apt-get --quiet 2 update
sudo apt-get --quiet 2 upgrade
sudo apt-get --quiet 2 dist-upgrade
