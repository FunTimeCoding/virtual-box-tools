#!/bin/sh -e
# To uninstall, delete the PREFIX directory.

USER_ID=$(id -u)

if [ ! "${USER_ID}" = "0" ]; then
    NOT_IN_STAFF=false
    groups | grep staff > /dev/null || NOT_IN_STAFF=true

    if [ "${NOT_IN_STAFF}" = true ]; then
        echo "You must be in the staff group."

        exit 1
    fi
fi

VERSION="3.5.0"
NAME="Python-${VERSION}"
FILE="${NAME}.tgz"
TEMPORARY_DIRECTORY="/tmp/${NAME}"
TEMPORARY_FILE="/tmp/${FILE}"
cd /tmp || exit 1

if [ ! -f "${TEMPORARY_FILE}" ]; then
    wget "https://www.python.org/ftp/python/${VERSION}/${FILE}"
fi

if [ ! -d "${TEMPORARY_DIRECTORY}" ]; then
    tar -zxf "${TEMPORARY_FILE}"
fi

PREFIX="/usr/local/opt/python-${VERSION}"

if [ ! -d "${PREFIX}" ]; then
    cd "${TEMPORARY_DIRECTORY}" || exit 1
    ./configure --prefix="${PREFIX}" --without-ensurepip
    make
    make install
fi

if [ "${1}" = "--clean" ]; then
    rm "${TEMPORARY_FILE}"
    rm -rf "${TEMPORARY_DIRECTORY}"
fi

echo "Python 3 script done."
