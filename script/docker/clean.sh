#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../../configuration/project.sh"

script/docker/remove.sh

# Remove image.
docker images | grep --quiet "${PROJECT_NAME_DASH}" && FOUND=true || FOUND=false

if [ "${FOUND}" = true ]; then
    docker rmi "${VENDOR_NAME_LOWER}/${PROJECT_NAME_DASH}"
fi

# Remove dangling image identifiers, and more.
docker system prune
