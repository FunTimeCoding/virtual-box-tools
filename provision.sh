#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive
apt-get --quiet 2 install neovim multitail htop git tree twine build-essential devscripts python3-dev python3-venv libyaml-dev libenchant-dev hunspell shellcheck python3-all python3-flask python3-yaml

sudo -u vagrant touch /home/vagrant/.pypirc
chmod 600 /home/vagrant/.pypirc
cat /vagrant/tmp/pypirc > /home/vagrant/.pypirc
