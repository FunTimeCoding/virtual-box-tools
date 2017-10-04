#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive
apt-get --quiet 2 install neovim multitail htop git tree twine build-essential devscripts python3-dev python3-venv libyaml-dev libenchant-dev hunspell shellcheck python3-all python3-flask python3-yaml pass

sudo -u vagrant touch /home/vagrant/.pypirc
chmod 600 /home/vagrant/.pypirc
cat /vagrant/tmp/pypirc > /home/vagrant/.pypirc

sudo -u vagrant touch /home/vagrant/.virtual-box-tools.yaml
chmod 600 /home/vagrant/.virtual-box-tools.yaml
cat /vagrant/virtual-box-tools.yaml > /home/vagrant/.virtual-box-tools.yaml

USER=$(cat /vagrant/tmp/user)
FULL_NAME=$(cat /vagrant/tmp/full-name)
DOMAIN=$(cat /vagrant/tmp/domain)
EMAIL="${USER}@${DOMAIN}"
export GNUPGHOME=/tmp/generate-key
mkdir -p /tmp/generate-key
chmod 700 /tmp/generate-key
gpg2 --batch --gen-key /vagrant/tmp/settings.txt
mkdir -p /vagrant/tmp/key-output
gpg2 --export --armor "{FULL_NAME}"> "/vagrant/tmp/key-output/${USER}.gpg-public-key.asc"
gpg2 --export-secret-key --armor "{FULL_NAME}" > "/vagrant/tmp/key-output/${USER}.gpg-private-key.asc"
rm -rf /tmp/generate-key

KEY_IDENTIFIER=$()
pass init "${KEY_IDENTIFIER}"
