#!/bin/sh -e

echo "Delete cached and other generated files."
FILES="build .pyvenv .coverage .cache .tox"

for FILE in ${FILES}; do
    if [ -e "${FILE}" ]; then
        echo "./${FILE}"
        rm -rf "${FILE}"
    fi
done

find . \( -name '__pycache__' -or -name '*.pyc' \)
find . \( -name '__pycache__' -or -name '*.pyc' \) -delete
