#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../../lib/project.sh"

rm -rf debian/debhelper-build-stamp
rm -rf debian/files
rm -rf "debian/${PROJECT_NAME}.substvars"
rm -rf "debian/${PROJECT_NAME}"
dpkg-buildpackage -b
