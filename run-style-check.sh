#!/bin/sh -e

if [ "$(command -v shellcheck || true)" = "" ]; then
    echo "Command not found: shellcheck"

    exit 1
fi

find . \( -name '*.sh' -and -not -path '*/.vim/*' \) -exec sh -c 'shellcheck ${1} || true' '_' '{}' \;
