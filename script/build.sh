#!/bin/sh -e

rm -rf build
id -u vagrant > /dev/null 2>&1 && VAGRANT_ENVIRONMENT='true' || VAGRANT_ENVIRONMENT='false'

if [ "${VAGRANT_ENVIRONMENT}" = true ]; then
    VIRTUAL_ENVIRONMENT_PATH='/home/vagrant/venv'
else
    VIRTUAL_ENVIRONMENT_PATH='.venv'
fi

if [ ! -d "${VIRTUAL_ENVIRONMENT_PATH}" ]; then
    python3 -m venv "${VIRTUAL_ENVIRONMENT_PATH}"
fi

# shellcheck source=/dev/null
. "${VIRTUAL_ENVIRONMENT_PATH}/bin/activate"
pip3 install --upgrade pip
pip3 install wheel
pip3 install --requirement requirements.txt
pip3 install --editable .
script/check.sh --ci-mode
script/measure.sh --ci-mode
script/test.sh --ci-mode
./setup.py bdist_wheel --dist-dir build
SYSTEM=$(uname)

if [ "${SYSTEM}" = Linux ]; then
    script/debian/package.sh
fi

script/publish.sh --ci-mode
# TODO: Finish implementation.
#script/docker/build.sh
