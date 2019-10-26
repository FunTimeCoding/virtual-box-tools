#!/bin/sh -e

SYSTEM=$(uname)

if [ "${SYSTEM}" = Linux ]; then
    if [ "$(command -v lsb_release || true)" = '' ]; then
        if [ -f /etc/debian_version ]; then
            VERSION=$(cut -c 1-1 < /etc/debian_version)
        fi
    else
        VERSION=$(lsb_release --release --short)
    fi

    if [ "${VERSION}" = 8 ]; then
        CODENAME=jessie
    elif [ "${VERSION}" = 9 ]; then
        CODENAME=stretch
    elif [ "${VERSION}" = 10 ]; then
        CODENAME=buster
    elif [ "${VERSION}" = 16.04 ]; then
        CODENAME=xenial
    elif [ "${VERSION}" = 18.04 ]; then
        CODENAME=bionic
    else
        echo "Operating system not supported."

        exit 1
    fi
fi

if [ "$(command -v vboxmanage || true)" = '' ]; then
    if [ "${SYSTEM}" = Darwin ]; then
        brew cask install virtualbox
    else
        grep --quiet virtualbox /etc/apt/sources.list /etc/apt/sources.list.d/* && FOUND=true || FOUND=false

        if [ "${FOUND}" = false ]; then
            wget --quiet --output-document - https://www.virtualbox.org/download/oracle_vbox_2016.asc | sudo apt-key add -
            echo "deb http://download.virtualbox.org/virtualbox/debian ${CODENAME} contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list
        fi

        sudo apt-get --quiet 2 update
        sudo apt-get --quiet 2 install virtualbox-5.2
    fi
fi

if [ "$(command -v vagrant || true)" = '' ]; then
    if [ "${SYSTEM}" = Darwin ]; then
        brew cask install vagrant
    else
        VAGRANT_VERSION=2.2.1
        wget --no-verbose --output-document /tmp/vagrant.deb "https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.deb"
        sudo dpkg --install /tmp/vagrant.deb
    fi
fi
