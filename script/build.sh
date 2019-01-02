#!/bin/sh -e

rm -rf build
id -u vagrant > /dev/null && VAGRANT_ENVIRONMENT='true' || VAGRANT_ENVIRONMENT='false'

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

if [ "${GIT_BRANCH}" = '' ]; then
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

if [ "${GIT_BRANCH}" = master ]; then
    script/python/publish.sh

    if [ "${SYSTEM}" = Linux ]; then
        script/debian/publish.sh
    fi
fi

# TODO: Finish implementation.
#script/docker/build.sh
