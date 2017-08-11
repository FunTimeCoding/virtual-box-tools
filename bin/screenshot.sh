#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)

usage()
{
    echo "Usage: ${0} NAME"
}

# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}"/../lib/virtual_box_tools.sh
NAME="${1}"

if [ "${NAME}" = "" ]; then
    usage

    exit 1
fi

${VBOXMANAGE} controlvm "${NAME}" screenshotpng /tmp/screen.png
