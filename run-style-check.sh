#!/bin/sh -e

CI_MODE=0

if [ "${1}" = "--ci-mode" ]; then
    shift
    CI_MODE=1
    mkdir -p build/log
fi

echo "================================================================================"
echo
echo "Running PEP8."

if [ "${CI_MODE}" = "1" ]; then
    pep8 --exclude=.git,.tox,.pyvenv,__pycache__ --statistics . | tee build/log/pep8.txt || true
else
    pep8 --exclude=.git,.tox,.pyvenv,__pycache__ --statistics . || true
fi

echo
echo "================================================================================"
echo
echo "Running PyLint."
OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = "Darwin" ]; then
    FIND="gfind"
else
    FIND="find"
fi

RESULT=$(${FIND} . -type f -name '*.py' -size -4096c -regextype posix-extended ! -regex '^.*/(.pyvenv|.tox|.git)/.*$')
RETURN_CODE=0

if [ "${CI_MODE}" = "1" ]; then
    # TODO: Fix this warning. It's tricky. Adding quotes will break pylint.
    # shellcheck disable=SC2086
    pylint --rcfile=.pylintrc ${RESULT} | tee build/log/pylint.txt || RETURN_CODE=$?
else
    # shellcheck disable=SC2086
    pylint --rcfile=.pylintrc ${RESULT} || RETURN_CODE=$?
fi

if [ ! "${RETURN_CODE}" = "0" ]; then
    echo "Return code: ${RETURN_CODE}"
    echo
fi

echo "================================================================================"
echo
echo "Running ShellCheck."
# shellcheck disable=SC2016
find . -name '*.sh' -exec sh -c 'shellcheck ${1} || true' '_' '{}' \;
echo
echo "================================================================================"
