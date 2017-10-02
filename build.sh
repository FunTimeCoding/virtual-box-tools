#!/bin/sh -e

rm -rf build

if [ ! -d .venv ]; then
    python3 -m venv .venv
fi

# shellcheck source=/dev/null
. .venv/bin/activate
pip3 install wheel
pip3 install --requirement requirements.txt
pip3 install --editable .
./spell-check.sh --ci-mode
./style-check.sh --ci-mode
#./metrics.sh --ci-mode
./tests.sh --ci-mode
./setup.py bdist_wheel --dist-dir build
SYSTEM=$(uname)

if [ "${SYSTEM}" = Linux ]; then
    ./package.sh
fi
