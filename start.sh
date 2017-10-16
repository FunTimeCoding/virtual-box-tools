#!/bin/sh -e

if [ ! -d build ]; then
    ./build.sh
fi

id -u vagrant > /dev/null && IS_VAGRANT_ENVIRONMENT=true || IS_VAGRANT_ENVIRONMENT=false

if [ "${IS_VAGRANT_ENVIRONMENT}" = true ]; then
    VIRTUAL_ENVIRONMENT_PATH=/home/vagrant/venv
else
    VIRTUAL_ENVIRONMENT_PATH=.venv
fi

# shellcheck source=/dev/null
. "${VIRTUAL_ENVIRONMENT_PATH}/bin/activate"

vbt-web-service
