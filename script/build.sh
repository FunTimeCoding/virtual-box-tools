#!/bin/sh -e

rm -rf build
script/python/venv.sh
# shellcheck source=/dev/null
. "${HOME}/venv/bin/activate"
pip3 install --upgrade pip
pip3 install wheel
pip3 install --requirement requirements.txt
pip3 install --editable .
script/check.sh --ci-mode
script/test.sh --ci-mode
script/measure.sh --ci-mode
#SYSTEM=$(uname)
#
# TODO: Needs polish.
#if [ "${SYSTEM}" = Linux ]; then
#    script/debian/package.sh
#    script/docker/build.sh
#    script/python/package.sh
#    script/publish.sh --ci-mode
#fi
