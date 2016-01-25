#!/bin/sh -e

if [ "${1}" = "--ci-mode" ]; then
    shift
    mkdir -p build/log
    sonar-runner | tee build/log/sonar-runner.log
    rm -rf .sonar
else
    echo "This script is only meant to run from continuous integration."
fi
