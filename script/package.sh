#!/bin/sh -e

NAME=virtual-box-tools
PROJECT_VERSION=0.1.0
ARCHIVE="${NAME}_${PROJECT_VERSION}.orig.tar.gz"
PROJECT_ROOT="${NAME}-${PROJECT_VERSION}"
PACKAGE_VERSION=1
COMBINED_VERSION="${PROJECT_VERSION}-${PACKAGE_VERSION}"

if [ ! -f debian/changelog ]; then
    dch --create -v "${COMBINED_VERSION}" --package "${NAME}"
fi

mkdir -p build
tar --create --gzip --transform "s,^,${PROJECT_ROOT}/," --exclude='./build' --exclude './.venv' --exclude './.tmp' --exclude './.idea' --exclude './.git' --exclude './.vagrant' --exclude './virtual_box_tools.egg-info' --file "build/${ARCHIVE}" .
cd build
tar --extract --file "${ARCHIVE}"
cd "${PROJECT_ROOT}"
debuild -us -uc
