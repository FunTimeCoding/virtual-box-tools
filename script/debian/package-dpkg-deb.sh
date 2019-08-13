#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../../lib/project.sh"

mkdir -p build/root-directory/usr/bin
cp bin/other build/root-directory/usr/bin
mkdir -p build/root-directory/DEBIAN
echo "Package: ${PROJECT_NAME}
Version: ${COMBINED_VERSION}
Architecture: all
Maintainer: ${MAINTAINER} <${EMAIL}>
Depends: python
Description: simple example package
 Very simple example package using dpkg-deb.
 The python dependency is an example." > build/root-directory/DEBIAN/control
dpkg-deb --build build/root-directory "build/${PROJECT_NAME}_${PROJECT_VERSION}_all.deb"
