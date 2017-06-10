#!/bin/sh -e

if [ ! "${VIRTUAL_ENV}" = "" ]; then
    echo "Virtual environment is still active."

    exit 1
fi

FILES="build
.venv
.coverage
.cache
.tox"

for FILE in ${FILES}; do
    if [ -e "${FILE}" ]; then
        rm -rf "${FILE}"
    fi
done

find . \( -name '__pycache__' -or -name '*.pyc' \) -delete
