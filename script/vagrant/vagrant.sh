#!/bin/sh -e

if [ ! -f "${HOME}/.ssh/id_rsa" ]; then
    ssh-keygen -C "vagrant@localhost" -N "" -f "${HOME}/.ssh/id_ansible"
    cat "${HOME}/.ssh/id_ansible.pub" >> "${HOME}/.ssh/authorized_keys"
    sudo mkdir -p -m 700 /root/.ssh
    sudo cp "${HOME}/.ssh/id_ansible.pub" /root/.ssh/authorized_keys
    sudo chmod 600 /root/.ssh/authorized_keys
fi

cp /vagrant/configuration/ssh.txt /home/vagrant/.ssh/config
cp /vagrant/configuration/inputrc.txt /home/vagrant/.inputrc
