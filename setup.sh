#!/bin/sh -e

SYSTEM=$(uname)

if [ "${SYSTEM}" = Linux ]; then
    sudo apt-get --quiet 2 install libenchant-dev bc
fi

pip3 install --upgrade --requirement requirements.txt
pip3 install --editable .
