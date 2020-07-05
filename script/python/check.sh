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

CONCERN_FOUND=false
CONTINUOUS_INTEGRATION_MODE=false

if [ "${1}" = --ci-mode ]; then
    shift
    mkdir -p build/log
    CONTINUOUS_INTEGRATION_MODE=true
fi

SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    FIND='gfind'
else
    FIND='find'
fi

PYCODESTYLE_CONCERNS=$(pycodestyle --exclude=.git,.tox,__pycache__ --statistics . 2>&1) || true

if [ ! "${PYCODESTYLE_CONCERNS}" = '' ]; then
    CONCERN_FOUND=true
    echo
    echo "[WARNING] PEP8 concerns:"
    echo
    echo "${PYCODESTYLE_CONCERNS}"
fi

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    echo "${PYCODESTYLE_CONCERNS}" >build/log/pycodestyle.txt
fi

PYTHON_FILES=$(${FIND} . -regextype posix-extended -type f -name '*.py' -regex "${INCLUDE_FILTER}" ! -regex "${INCLUDE_STILL_FILTER}")
RETURN_CODE=0
# shellcheck disable=SC2086
PYLINT_OUTPUT=$(pylint ${PYTHON_FILES}) || RETURN_CODE=$?
echo
echo "[NOTICE] Pylint report:"
echo "${PYLINT_OUTPUT}"

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    echo "${PYLINT_OUTPUT}" >build/log/pylint.txt
fi

if [ ! "${RETURN_CODE}" = 0 ]; then
    echo
    echo "Pylint return code: ${RETURN_CODE}"
fi

RETURN_CODE=0
MYPY_OUTPUT=$(mypy --ignore-missing-imports .) || RETURN_CODE=$?

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    echo "${MYPY_OUTPUT}" >build/log/mypy.txt
fi

if [ ! "${RETURN_CODE}" = 0 ]; then
    if [ ! "${MYPY_OUTPUT}" = '' ]; then
        CONCERN_FOUND=true
        echo
        echo "[WARNING] Mypy concerns:"
        echo
        echo "${MYPY_OUTPUT}"
        echo
        echo "Mypy return code: ${RETURN_CODE}"
    fi
fi

if [ "${CONCERN_FOUND}" = true ]; then
    echo
    echo "Warning level concern(s) found." >&2

    exit 2
fi
