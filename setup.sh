#!/bin/sh -e

if [ "${1}" = --help ]; then
    echo "Usage: ${0} [--development]"
fi

if [ "${1}" = --development ]; then
    wget --quiet --output-document - cfg.greenshininglake.org/python3.sh | sh -e
    wget --quiet --output-document - cfg.greenshininglake.org/shellcheck.sh | sh -e
fi

SYSTEM=$(uname)

if [ "${SYSTEM}" = Linux ]; then
    sudo apt-get --quiet 2 install libenchant-dev bc
fi

pip3 install --upgrade --requirement requirements.txt
pip3 install --editable .
