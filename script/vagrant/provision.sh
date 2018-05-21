#!/bin/sh -e

export DEBIAN_FRONTEND=noninteractive
apt-get --quiet 2 install neovim multitail htop git tree twine build-essential devscripts python3-dev python3-venv libenchant-dev hunspell shellcheck python3-all

touch /home/vagrant/.pypirc
chmod 600 /home/vagrant/.pypirc
cat /vagrant/tmp/pypirc.txt > /home/vagrant/.pypirc

touch /home/vagrant/.virtual-box-tools.yaml
chmod 600 /home/vagrant/.virtual-box-tools.yaml
cat /vagrant/virtual-box-tools.yaml > /home/vagrant/.virtual-box-tools.yaml

# Get first line only using head, because create.bat adds a blank line. Also remove newline characters.
USER_NAME=$(cat /vagrant/tmp/user-name.txt | head -n 1 | sed --expression 's/[\r\n]//g')
FULL_NAME=$(cat /vagrant/tmp/full-name.txt | head -n 1 | sed --expression 's/[\r\n]//g')
DOMAIN=$(cat /vagrant/tmp/domain.txt | head -n 1 | sed --expression 's/[\r\n]//g')

echo "REAL_NAME='${FULL_NAME}'
EMAIL='${USER_NAME}@${DOMAIN}'
KEY_SERVER='keyserver.ubuntu.com'" > "${HOME}/.gnu-privacy-guard-tools.sh"

# GNUPGHOME needs specific permissions which do not work over network sharing.
mkdir -p /home/vagrant/gnu-privacy-guard-home
chmod 700 /home/vagrant/gnu-privacy-guard-home
export GNUPGHOME=/home/vagrant/gnu-privacy-guard-home

/vagrant/gnu-privacy-guard-tools/bin/generate-key.sh --type signature --purpose 'Debian package' --virtual
/vagrant/gnu-privacy-guard-tools/bin/export-public-key.sh --output-file "/vagrant/tmp/${USER_NAME}.gpg-public-key.asc" "${FULL_NAME}"

# Required for non-interactive private key export.
echo allow-loopback-pinentry > "${GNUPGHOME}/gpg-agent.conf"
/vagrant/gnu-privacy-guard-tools/bin/reload-agent.sh

grep --only-matching --perl-regexp '(?<=Passphrase: ).*' tmp/settings.txt > /vagrant/tmp/password.txt
/vagrant/gnu-privacy-guard-tools/bin/export-public-key.sh --passphrase-file /vagrant/tmp/password.txt --output-file "/vagrant/tmp/${USER_NAME}.gpg-private-key.asc" "${FULL_NAME}"
#KEY_IDENTIFIER=$()
#pass init "${KEY_IDENTIFIER}"