#!/bin/sh -e

git pull

# If .gitmodules has changed.
git submodule sync

# If new submodules were added in upstream.
git submodule update --init

# If the head is detached on any of them.
git submodule foreach git checkout master

# TODO: Accept failing pulls when not in the correct networks. Find a better solution?
#git submodule foreach git pull
SUBMODULES=$(git config --file .gitmodules --get-regexp path | awk '{ print $2 }')
CURRENT_DIRECTORY="${PWD}"

for SUBMODULE in ${SUBMODULES}; do
    echo "${SUBMODULE}"
    cd "${CURRENT_DIRECTORY}/${SUBMODULE}"
    git pull || true
done
