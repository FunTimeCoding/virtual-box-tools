#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive
apt-get --quiet 2 install neovim multitail htop git tree twine build-essential devscripts python3-dev python3-venv libyaml-dev libenchant-dev hunspell shellcheck python3-all python3-flask python3-yaml pass pwgen rng-tools
cp /vagrant/rng-tools /etc/default/rng-tools
systemctl restart rng-tools
sudo -u vagrant sh -e /vagrant/vagrant.sh
