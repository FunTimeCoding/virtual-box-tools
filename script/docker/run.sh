#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../../configuration/project.sh"

if [ "${1}" = --development ]; then
    DEVELOPMENT=true
    shift
else
    DEVELOPMENT=false
fi

if [ "${DEVELOPMENT}" = true ]; then
    WORKING_DIRECTORY=$(pwd)
    # shellcheck disable=SC2068
    docker run --interactive --tty --rm --name "${PROJECT_NAME_DASH}" --volume "${WORKING_DIRECTORY}:/${PROJECT_NAME_DASH}" "${VENDOR_NAME_LOWER}/${PROJECT_NAME_DASH}" $@
else
    # shellcheck disable=SC2068
    docker run --interactive --tty --rm --name "${PROJECT_NAME_DASH}" "${VENDOR_NAME_LOWER}/${PROJECT_NAME_DASH}" $@
fi
