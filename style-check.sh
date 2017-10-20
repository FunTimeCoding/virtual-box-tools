#!/bin/sh -e

if [ "$(command -v shellcheck || true)" = "" ]; then
    echo "Command not found: shellcheck"

    exit 1
fi

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
    FIND=gfind
else
    FIND=find
fi

INCLUDE_FILTER="^.*(\/bin\/[a-z]*|\.py)$"
EXCLUDE_FILTER="^.*\/(build|tmp|\.git|\.vagrant|\.idea|\.venv|\.tox)\/.*$"

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    FILES=$(${FIND} . -name '*.sh' -regextype posix-extended ! -regex "${EXCLUDE_FILTER}" -printf '%P\n')

    for FILE in ${FILES}; do
        FILE_REPLACED=$(echo "${FILE}" | sed 's/\//-/')
        shellcheck --format checkstyle "${FILE}" > "build/log/checkstyle-${FILE_REPLACED}.xml" || true
    done
else
    # shellcheck disable=SC2016
    SHELL_SCRIPT_CONCERNS=$(${FIND} . -name '*.sh' -regextype posix-extended ! -regex "${EXCLUDE_FILTER}" -exec sh -c 'shellcheck ${1} || true' '_' '{}' \;)

    if [ ! "${SHELL_SCRIPT_CONCERNS}" = "" ]; then
        CONCERN_FOUND=true
        echo "(WARNING) Shell script concerns:"
        echo "${SHELL_SCRIPT_CONCERNS}"
    fi
fi

EXCLUDE_FILTER_WITH_INIT="^.*\/((build|tmp|\.git|\.vagrant|\.idea|\.venv|\.tox)\/.*|__init__\.py)$"
# shellcheck disable=SC2016
EMPTY_FILES=$(${FIND} . -empty -regextype posix-extended ! -regex "${EXCLUDE_FILTER_WITH_INIT}")

if [ ! "${EMPTY_FILES}" = "" ]; then
    CONCERN_FOUND=true

    if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
        echo "${EMPTY_FILES}" > build/log/empty-files.txt
    else
        echo
        echo "(WARNING) Empty files:"
        echo
        echo "${EMPTY_FILES}"
    fi
fi

# shellcheck disable=SC2016
TO_DOS=$(${FIND} . -regextype posix-extended -type f -and ! -regex "${EXCLUDE_FILTER}" -exec sh -c 'grep -Hrn TODO "${1}" | grep -v "${2}"' '_' '{}' '${0}' \;)

if [ ! "${TO_DOS}" = "" ]; then
    if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
        echo "${TO_DOS}" > build/log/to-dos.txt
    else
        echo
        echo "(NOTICE) To dos:"
        echo
        echo "${TO_DOS}"
    fi
fi

# shellcheck disable=SC2016
SHELLCHECK_IGNORES=$(${FIND} . -regextype posix-extended -type f -and ! -regex "${EXCLUDE_FILTER}" -exec sh -c 'grep -Hrn "# shellcheck" "${1}" | grep -v "${2}"' '_' '{}' '${0}' \;)

if [ ! "${SHELLCHECK_IGNORES}" = "" ]; then
    if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
        echo "${SHELLCHECK_IGNORES}" > build/log/shellcheck-ignores.txt
    else
        echo
        echo "(NOTICE) Shellcheck ignores:"
        echo
        echo "${SHELLCHECK_IGNORES}"
    fi
fi

PEP8_CONCERNS=$(pep8 --exclude=.git,.tox,.venv,__pycache__ --statistics .) || RETURN_CODE=$?

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    echo "${PEP8_CONCERNS}" > build/log/pep8.txt
else
    if [ ! "${PEP8_CONCERNS}" = "" ]; then
        CONCERN_FOUND=true
        echo
        echo "(WARNING) PEP8 concerns:"
        echo
        echo "${PEP8_CONCERNS}"
    fi
fi

PYTHON_FILES=$(${FIND} . -type f -regextype posix-extended -regex "${INCLUDE_FILTER}" -and ! -regex "${EXCLUDE_FILTER}")
RETURN_CODE=0
# shellcheck disable=SC2086
PYLINT_OUTPUT=$(pylint ${PYTHON_FILES}) || RETURN_CODE=$?

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    echo  | tee build/log/pylint.txt
    echo "(NOTICE) Pylint" | tee --append build/log/pylint.txt
    echo "${PYLINT_OUTPUT}" | tee --append build/log/pylint.txt
else
    echo
    echo "(NOTICE) Pylint"
    echo "${PYLINT_OUTPUT}"
fi

if [ ! "${RETURN_CODE}" = 0 ]; then
    echo "Pylint return code: ${RETURN_CODE}"
fi

if [ "${CONCERN_FOUND}" = true ]; then
    if [ "${CONTINUOUS_INTEGRATION_MODE}" = false ]; then
        echo
        echo "Concern(s) of category WARNING found." >&2
    fi

    exit 2
fi
