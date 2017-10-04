#!/bin/sh -e

touch tmp/pypirc
chmod 600 tmp/pypirc
cat "${HOME}/.pypirc" > tmp/pypirc

USER=$(whoami)
echo "${USER}" > tmp/user
SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    FULL_NAME=$(scutil --get HostName)
else
    FULL_NAME=$(getent passwd "${USER}" | cut -d : -f 5 | cut -d , -f 1)
fi

echo "${FULL_NAME}" > tmp/full-name

vagrant up
