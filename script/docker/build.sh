#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../../lib/project.sh"

docker images | grep --quiet "${VENDOR_NAME_LOWER}/${PROJECT_NAME}" && FOUND=true || FOUND=false

if [ "${FOUND}" = true ]; then
    docker rmi "${VENDOR_NAME_LOWER}/${PROJECT_NAME}"
fi

docker build --tag "${VENDOR_NAME_LOWER}/${PROJECT_NAME}" .
