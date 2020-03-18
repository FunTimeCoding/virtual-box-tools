#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../../configuration/project.sh"

MESSAGE="${1}"

if [ "${MESSAGE}" = '' ]; then
    echo "Usage: ${0} MESSAGE"

    exit 1
fi

if [ ! -f debian/changelog ]; then
    dch --create --newversion "${COMBINED_VERSION}" --package "${PROJECT_NAME_DASH}" "Initial release."
fi

dch --newversion "${COMBINED_VERSION}" "${MESSAGE}"
dch --release 'dummy argument'
