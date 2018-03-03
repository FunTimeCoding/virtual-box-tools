#!/bin/sh -e

if [ "${1}" = --ci-mode ]; then
    shift
    SYSTEM=$(uname)

    if [ "${SYSTEM}" = Darwin ]; then
        TEE='gtee'
    else
        TEE='tee'
    fi

    mkdir -p build/log
    py.test -c .pytest-ci.ini "$@" | "${TEE}" build/log/pytest.log
else
    py.test -c .pytest.ini "$@"
fi
