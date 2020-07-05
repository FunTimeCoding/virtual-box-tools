#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(
    cd "${DIRECTORY}" || exit 1
    pwd
)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../../configuration/project.sh"
"${HOME}/src/continuous-integration-tools/bin/jenkins/update-job.sh" "${PROJECT_NAME_DASH}" configuration/job.xml
"${HOME}/src/continuous-integration-tools/bin/jenkins/build.sh" "${PROJECT_NAME_DASH}"
