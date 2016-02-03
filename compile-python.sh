#!/bin/sh -e

OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = "Linux" ]; then
    sudo apt-get install build-essential libssl-dev
fi

if [ "$(command -v python3 || true)" = "" ]; then
    OUTPUT=$(wget cfg.shiin.org/python3.sh -O - | sh -e) && ERROR=false || ERROR=true
    PREFIX="${OUTPUT#PREFIX: *}"

    if [ "${ERROR}" = false ]; then
        export PATH="${PREFIX}/bin:${PATH}"
    fi
fi

if [ "$(command -v pip3 || true)" = "" ]; then
    python3 -m ensurepip --user
fi

pip3 install --upgrade --user pip
pip3 install --upgrade --user setuptools
