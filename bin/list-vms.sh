#!/bin/sh -e

DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)
. "${SCRIPT_DIR}/../lib/virtual_box_tools.sh"
${MANAGE_COMMAND} list runningvms | awk -F'"' '{ print $2 }'
