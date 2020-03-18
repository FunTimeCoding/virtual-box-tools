#!/bin/sh -e

# Development mode mounts the project root so it can be edited and re-ran without rebuilding the image and recreating the container.

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../../configuration/project.sh"

if [ "${1}" = --development ]; then
    DEVELOPMENT=true
else
    DEVELOPMENT=false
fi

docker ps --all | grep --quiet "${PROJECT_NAME_DASH}" && FOUND=true || FOUND=false

if [ "${FOUND}" = false ]; then
    WORKING_DIRECTORY=$(pwd)

    if [ "${DEVELOPMENT}" = true ]; then
        docker create --name "${PROJECT_NAME_DASH}" --volume "${WORKING_DIRECTORY}:/${PROJECT_NAME_DASH}" "${VENDOR_NAME_LOWER}/${PROJECT_NAME_DASH}"
    else
        docker create --name "${PROJECT_NAME_DASH}" "${VENDOR_NAME_LOWER}/${PROJECT_NAME_DASH}"
    fi

    # TODO: Specifying the entry point overrides CMD in Dockerfile. Is this useful, or should all sub commands go through one entry point script? I'm inclined to say one entry point script per project.
    #docker create --name "${PROJECT_NAME_DASH}" --volume "${WORKING_DIRECTORY}:/${PROJECT_NAME_DASH}" --entrypoint "/${PROJECT_NAME_DASH}/bin/other" "${VENDOR_NAME_LOWER}/${PROJECT_NAME_DASH}"
    #docker create --name "${PROJECT_NAME_DASH}" "${VENDOR_NAME_LOWER}/${PROJECT_NAME_DASH}" "/${PROJECT_NAME_DASH}/bin/other"
    # TODO: Run tests this way?
    #docker create --name "${PROJECT_NAME_DASH}" "${VENDOR_NAME_LOWER}/${PROJECT_NAME_DASH}" "/${PROJECT_NAME_DASH}/script/docker/test.sh"
fi

docker start --attach "${PROJECT_NAME_DASH}"
