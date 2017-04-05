#!/bin/sh -e

LAST_VERSION=1.6.4
VERSION=$(pylint --version 2>&1 | grep pylint | sed 's/[^0-9.]*\([0-9.]*\).*/\1/')

if [ "${LAST_VERSION}" = "${VERSION}" ]; then
    echo "Config is up to date."

    exit 0
fi

# This is a regular expression that never matches with an argument name because empty string would falsely match with all of them.
# That would obscure results.
NON_MATCHING_REGULAR_EXPRESSION=RegularExpressionThatNeverMatches
BAD_NAMES=foo,bar,baz
OPERATING_SYSTEM=$(uname)

if [ "${OPERATING_SYSTEM}" = Darwin ]; then
    DICTIONARY=en_US
else
    DICTIONARY=en
fi

# missing-docstring: Clean code does not require doc strings everywhere
# redefined-variable-type: Falsely reports inherited return types.
pylint --disable missing-docstring,redefined-variable-type --max-returns 1 --max-args 2 --max-module-lines 300 --max-statements 10 --max-line-length 80 --min-public-methods 1 --max-public-methods 10 --max-parents 3 --max-attributes 3 --max-locals 5 --max-branches 5 --max-bool-expr 1 --max-nested-blocks 3 --ignored-argument-names "${NON_MATCHING_REGULAR_EXPRESSION}" --ignore-long-lines "${NON_MATCHING_REGULAR_EXPRESSION}" --good-names '' --bad-names "${BAD_NAMES}" --notes TODO --expected-line-ending-format LF --no-space-check '' --ignore .git --persistent no --spelling-dict "${DICTIONARY}" --spelling-private-dict-file custom.dic --generate-rcfile > .pylintrc
