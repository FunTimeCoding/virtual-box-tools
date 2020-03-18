#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../../configuration/project.sh"

docker ps --all | grep --quiet "${PROJECT_NAME_DASH}" && FOUND=true || FOUND=false

if [ "${FOUND}" = true ]; then
    docker rm "${PROJECT_NAME_DASH}"
fi
