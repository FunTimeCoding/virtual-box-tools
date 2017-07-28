#!/bin/sh -e

if [ "${1}" = --help ]; then
    echo "Usage: ${0} [--no-venv]"
fi

USE_VENV=true

if [ "${1}" = --no-venv ]; then
    USE_VENV=false
fi

SYSTEM=$(uname)

if [ "${SYSTEM}" = Linux ]; then
    LIST=$(dpkg --list)
    echo "${LIST}" | grep --quiet 'ii  libenchant-dev' && FOUND=true || FOUND=false

    if [ "${FOUND}" = false ]; then
        sudo apt-get --quiet 2 install libenchant-dev
    fi

    echo "${LIST}" | grep --quiet 'ii  hunspell' && FOUND=true || FOUND=false

    if [ "${FOUND}" = false ]; then
        sudo apt-get --quiet 2 install hunspell
    fi

    echo "${LIST}" | grep --quiet 'ii  bc' && FOUND=true || FOUND=false

    if [ "${FOUND}" = false ]; then
        sudo apt-get --quiet 2 install bc
    fi
fi

if [ "${USE_VENV}" = true ]; then
    if [ ! -d .venv ]; then
        python3 -m venv .venv
    fi

    . .venv/bin/activate
fi

pip3 install --upgrade --requirement requirements.txt
pip3 install --editable .
