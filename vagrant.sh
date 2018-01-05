#!/bin/sh -e

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
EMAIL="${USER_NAME}@${DOMAIN}"
PASSWORD=$(pwgen 14 1)
echo "${PASSWORD}" > /vagrant/tmp/password.txt
echo "Key-Type: default
Subkey-Type: default
Name-Real: ${FULL_NAME}
Name-Comment: Debian package signature key
Name-Email: ${EMAIL}
Expire-Date: 1y
Passphrase: ${PASSWORD}" > /vagrant/tmp/settings.txt
# GNUPGHOME needs specific permissions which do not work over network sharing.
mkdir -p /home/vagrant/gnu-privacy-guard-home
chmod 700 /home/vagrant/gnu-privacy-guard-home
export GNUPGHOME=/home/vagrant/gnu-privacy-guard-home
gpg2 --batch --gen-key /vagrant/tmp/settings.txt
gpg2 --export --armor "${FULL_NAME}" > "/vagrant/tmp/${USER_NAME}.gpg-public-key.asc"
echo allow-loopback-pinentry > "${GNUPGHOME}/gpg-agent.conf"
gpg-connect-agent reloadagent /bye
gpg2 --batch --passphrase-fd 1 --passphrase-file /vagrant/tmp/password.txt --pinentry-mode loopback --export-secret-key --armor "${FULL_NAME}" > "/vagrant/tmp/${USER_NAME}.gpg-private-key.asc"
#KEY_IDENTIFIER=$()
#pass init "${KEY_IDENTIFIER}"
