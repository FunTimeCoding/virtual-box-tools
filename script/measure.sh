#!/bin/sh -e

SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    WC='gwc'
    FIND='gfind'
else
    WC='wc'
    FIND='find'
fi

FILES_EXCLUDE='^.*\/(build|tmp|\.git|\.vagrant|\.idea|\.venv|\.tox|__pycache__|[a-z_]+\.egg-info)\/.*$'
FILES=$(${FIND} . -type f -regextype posix-extended ! -regex "${FILES_EXCLUDE}" | ${WC} --lines)
DIRECTORIES_EXCLUDE='^.*\/(build|tmp|\.git|\.vagrant|\.idea|\.venv|\.tox|__pycache__)(\/.*)?$'
DIRECTORIES=$(${FIND} . -type d -regextype posix-extended ! -regex "${DIRECTORIES_EXCLUDE}" | ${WC} --lines)
INCLUDE='^.*\.py$'
CODE_EXCLUDE='^.*\/(build|tmp|\.git|\.vagrant|\.idea|\.venv|\.tox)\/.*$'
CODE=$(${FIND} . -type f -regextype posix-extended -regex "${INCLUDE}" -and ! -regex "${CODE_EXCLUDE}" | xargs cat)
LINES=$(echo "${CODE}" | ${WC} --lines)
NON_BLANK_LINES=$(echo "${CODE}" | grep --invert-match --regexp '^$' | ${WC} --lines)
echo "FILES: ${FILES}"
echo "DIRECTORIES: ${DIRECTORIES}"
echo "LINES: ${LINES}"
echo "NON_BLANK_LINES: ${NON_BLANK_LINES}"

if [ "${1}" = --ci-mode ]; then
    shift
    SYSTEM=$(uname)

    if [ "${SYSTEM}" = Darwin ]; then
        TEE='gtee'
    else
        TEE='tee'
    fi

    mkdir -p build/log
    sonar-runner | "${TEE}" build/log/sonar-runner.log
    rm -rf .sonar
fi
