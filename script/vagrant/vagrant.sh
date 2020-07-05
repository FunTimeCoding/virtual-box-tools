#!/bin/sh -e

if [ ! -f /home/vagrant/.ssh/id_rsa ]; then
    ssh-keygen -C vagrant@localhost -N '' -f /home/vagrant/.ssh/id_ansible
    cat /home/vagrant/.ssh/id_ansible.pub >>/home/vagrant/.ssh/authorized_keys
    sudo mkdir --parents --mode 700 /root/.ssh
    sudo cp /home/vagrant/.ssh/id_ansible.pub /root/.ssh/authorized_keys
    sudo chmod 600 /root/.ssh/authorized_keys
fi

if [ -d /vagrant/tmp/ssh ]; then
    cp /vagrant/tmp/ssh/id_rsa /home/vagrant/.ssh/id_rsa
    chmod 600 /home/vagrant/.ssh/id_rsa
    cp /vagrant/tmp/ssh/id_rsa.pub /home/vagrant/.ssh/id_rsa.pub
    chmod -x /home/vagrant/.ssh/id_rsa.pub
fi

cp /vagrant/configuration/ssh.txt /home/vagrant/.ssh/config
chmod -x /home/vagrant/.ssh/config
cp /vagrant/configuration/inputrc.txt /home/vagrant/.inputrc
chmod -x /home/vagrant/.inputrc
cp /vagrant/configuration/profile.sh /home/vagrant/.profile
chmod -x /home/vagrant/.profile
cp /vagrant/configuration/aliases.sh /home/vagrant/.aliases
chmod -x /home/vagrant/.aliases

if [ -f /vagrant/tmp/gitconfig.txt ]; then
    cp /vagrant/tmp/gitconfig.txt /home/vagrant/.gitconfig
    chmod -x /home/vagrant/.gitconfig
fi

if [ -f /vagrant/tmp/gitignore_global.txt ]; then
    cp /vagrant/tmp/gitignore_global.txt /home/vagrant/.gitignore_global
    chmod -x /home/vagrant/.gitignore_global
fi
