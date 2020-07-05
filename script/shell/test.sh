#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(
    cd "${DIRECTORY}" || exit 1
    pwd
)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../../configuration/project.sh"

if [ "${1}" = --help ]; then
    echo "Usage: ${0} [--ci-mode]"

    exit 0
fi

if [ "${1}" = --ci-mode ]; then
    shift
    mkdir -p build/log
    CONTINUOUS_INTEGRATION_MODE=true
fi

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    # TODO: Confirm the log contains anything useful. The coverage report could be in there.
    export SHELLSPEC_LOGFILE=build/log/shellspec.txt
    shellspec --no-color --kcov --format junit >build/log/junit.xml
    mv coverage build/log
else
    shellspec
fi
