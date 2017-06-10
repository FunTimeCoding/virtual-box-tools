#!/bin/sh -e

SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    WC=gwc
    FIND=gfind
else
    WC=wc
    FIND=find
fi

FILE_COUNT=$(${FIND} . -type f | ${WC} --lines)
echo "FILE_COUNT: ${FILE_COUNT}"

DIRECTORY_COUNT=$(${FIND} . -type d | ${WC} --lines)
echo "DIRECTORY_COUNT: ${DIRECTORY_COUNT}"

INCLUDE_FILTER="^.*(\/bin\/.*|\.py)$"
EXCLUDE_FILTER="^.*\/(build|tmp|\.git|\.vagrant|\.idea|\.venv|\.tox)\/.*$"
ALL_CODE=$(${FIND} . -type f -regextype posix-extended -regex "${INCLUDE_FILTER}" -and ! -regex "${EXCLUDE_FILTER}" | xargs cat)

LINE_COUNT=$(echo "${ALL_CODE}" | ${WC} --lines)
echo "LINE_COUNT: ${LINE_COUNT}"

NON_BLANK_LINE_COUNT=$(echo "${ALL_CODE}" | grep --invert-match --regexp '^$' | ${WC} --lines)
echo "NON_BLANK_LINE_COUNT: ${NON_BLANK_LINE_COUNT}"
