#!/bin/sh -e

configure_virtual_environment()
{
    if [ ! -d .pyvenv ]; then
        pyvenv .pyvenv
    fi

    # shellcheck source=/dev/null
    . .pyvenv/bin/activate
    pip3 install --upgrade --user pip
    pip3 install --upgrade --user setuptools
    pip3 install --upgrade --user --requirement requirements.txt | tee build/log/pip.log
}

mkdir -p build/log
# Virtual environment does not work with the Python interpreter and packages installed in the home directory.
#configure_virtual_environment
./run-style-check.sh --ci-mode
./run-metrics.sh --ci-mode
./run-tests.sh --ci-mode
