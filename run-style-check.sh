#!/bin/sh -e

find . -name '*.sh' -exec sh -c 'shellcheck ${1} || true' '_' '{}' \;
