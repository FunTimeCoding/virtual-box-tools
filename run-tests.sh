#!/bin/sh -e

if [ "${1}" = --ci-mode ]; then
    shift
    mkdir -p build/log
    py.test -c .pytest-ci.ini "$@" | tee build/log/pytest.log
else
    py.test -c .pytest.ini "$@"
fi
