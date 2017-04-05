#!/bin/sh -e

if [ "$(command -v shellcheck || true)" = "" ]; then
    echo "Command not found: shellcheck"

    exit 1
fi

CONTINUOUS_INTEGRATION_MODE=false

if [ "${1}" = --ci-mode ]; then
    shift
    mkdir -p build/log
    CONTINUOUS_INTEGRATION_MODE=true
fi

#     12345678901234567890123456789012345678901234567890123456789012345678901234567890
echo "================================================================================"
echo
echo "Running PEP8."

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    pep8 --exclude=.git,.tox,.pyvenv,__pycache__ --statistics . | tee build/log/pep8.txt || true
else
    pep8 --exclude=.git,.tox,.pyvenv,__pycache__ --statistics . || true
fi

echo
echo "================================================================================"
echo
echo "Running PyLint."
OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = Darwin ]; then
    FIND=gfind
else
    FIND=find
fi

RESULT=$(${FIND} . -type f -name '*.py' -or -path '*\/bin\/*' -regextype posix-extended ! -regex '^.*/(.pyvenv|.tox|.git)/.*$')
RETURN_CODE=0

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    # TODO: Fix this warning. It's tricky. Adding quotes will break pylint.
    # shellcheck disable=SC2086
    pylint --rcfile=.pylintrc ${RESULT} | tee build/log/pylint.txt || RETURN_CODE=$?
else
    # shellcheck disable=SC2086
    pylint --rcfile=.pylintrc ${RESULT} || RETURN_CODE=$?
fi

if [ ! "${RETURN_CODE}" = 0 ]; then
    echo "Return code: ${RETURN_CODE}"
    echo
fi

echo "================================================================================"
echo

echo "Run ShellCheck."

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    # shellcheck disable=SC2016
    find . -name '*.sh' -and -not -path '*/vendor/*' -exec sh -c 'shellcheck ${1} || true' '_' '{}' \; | tee build/log/shellcheck.txt
else
    # shellcheck disable=SC2016
    find . -name '*.sh' -and -not -path '*/vendor/*' -exec sh -c 'shellcheck ${1} || true' '_' '{}' \;
fi

echo
echo "================================================================================"
