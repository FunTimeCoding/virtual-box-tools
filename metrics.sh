#!/bin/sh -e

if [ "${1}" = --ci-mode ]; then
    shift
    SYSTEM=$(uname)

    if [ "${SYSTEM}" = Darwin ]; then
        TEE=gtee
    else
        TEE=tee
    fi

    mkdir -p build/log
    sonar-runner | "${TEE}" build/log/sonar-runner.log
    rm -rf .sonar
else
    echo "This script is only meant to run from continuous integration."
fi
