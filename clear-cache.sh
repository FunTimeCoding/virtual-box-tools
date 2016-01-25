#!/bin/sh -e

echo "Deleting cached and generated files."
DIR=$(dirname "${0}")
SCRIPT_DIR=$(cd "${DIR}" || exit 1; pwd)
FILES="build .pyvenv .coverage .cache .tox"

for FILE in ${FILES}; do
    if [ -e "${FILE}" ]; then
        echo "rm -rf ${FILE}"
        rm -rf "${SCRIPT_DIR:?}/${FILE}"
    fi
done

find "${SCRIPT_DIR}" \( -name '__pycache__' -o -name '*.pyc' -o -name '*.egg-info' \) -delete
