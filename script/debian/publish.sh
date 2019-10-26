#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../../lib/project.sh"
# shellcheck source=/dev/null
. "${HOME}/.debian_tools.sh"
curl -u "${PACKAGE_REPOSITORY_USERNAME}:${PACKAGE_REPOSITORY_PASSWORD}" -X POST -H "Content-Type: multipart/form-data" --data-binary "@build/python3-${NAME}_${COMBINED_VERSION}_amd64.deb" "https://${PACKAGE_REPOSITORY_SERVER}/repository/debian/"
