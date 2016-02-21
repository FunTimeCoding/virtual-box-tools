#!/bin/sh -e

OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = "Linux" ]; then
    FIND="find"
else
    FIND="gfind"
fi

# shellcheck disable=SC2016
${FIND} . -regextype posix-extended -type f -and ! -regex '^.*/(\.git|\.vim|\.idea)/.*$' -exec sh -c 'grep -Hrn TODO "${1}" | grep -v "${2}"' '_' '{}' '${0}' \;

# shellcheck disable=SC2016
${FIND} . -regextype posix-extended -type f -and ! -regex '^.*/(\.git|\.vim|\.idea)/.*$' -exec sh -c 'grep -Hrn "# shellcheck" "${1}" | grep -v "${2}"' '_' '{}' '${0}' \;
