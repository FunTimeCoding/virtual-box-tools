#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(
    cd "${DIRECTORY}" || exit 1
    pwd
)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../../configuration/project.sh"
"${HOME}/src/continuous-integration-tools/bin/jenkins/delete-job.sh" "${PROJECT_NAME_DASH}"
