#!/bin/sh -e

echo "Delete cached and generated files."
DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
FILES="build .pyvenv .coverage .cache .tox"

for FILE in ${FILES}; do
    if [ -e "${FILE}" ]; then
        echo "rm -rf ${FILE}"
        rm -rf "${SCRIPT_DIRECTORY:?}/${FILE}"
    fi
done

find "${SCRIPT_DIRECTORY}" \( -name '__pycache__' -o -name '*.pyc' -o -name '*.egg-info' \) -delete
