#!/bin/sh -e

mkdir -p build/log

if [ ! -d ".pyvenv" ]; then
    pyvenv .pyvenv
fi

# shellcheck source=/dev/null
. .pyvenv/bin/activate
pip3 install --upgrade --user pip
pip3 install --upgrade --user setuptools
pip3 install --upgrade --user --requirement requirements.txt | tee build/log/pip.log
./run-style-check.sh --ci-mode
./run-metrics.sh --ci-mode
./run-tests.sh --ci-mode
