#!/bin/sh -e

# shellcheck source=/dev/null
. "${HOME}/.aptly-tools.sh"

FILE_PATH="${1}"
REPOSITORY_NAME="${2}"
DISTRIBUTION="${3}"
PREFIX="${4}"

if [ "${FILE_PATH}" = '' ] || [ "${REPOSITORY_NAME}" = '' ] || [ "${DISTRIBUTION}" = '' ] || [ "${PREFIX}" = '' ]; then
    echo "Usage: ${0} FILE_PATH REPOSITORY_NAME DISTRIBUTION PREFIX"

    exit 1
fi

PACKAGE_NAME=$(basename "${FILE_PATH}")
PACKAGE_NAME="${PACKAGE_NAME%_*}"
PACKAGE_NAME="${PACKAGE_NAME%_*}"

echo "Upload:"
curl --user "${USERNAME}:${PASSWORD}" --request POST --form "file=@${FILE_PATH}" "https://${SERVER}/api/files/${PACKAGE_NAME}"
echo
echo "Import:"
curl --user "${USERNAME}:${PASSWORD}" --request POST "https://${SERVER}/api/repos/${REPOSITORY_NAME}/file/${PACKAGE_NAME}"
echo
echo "Publish:"
curl --user "${USERNAME}:${PASSWORD}" --request PUT --header 'Content-Type: application/json' --data '{}' "https://${SERVER}/api/publish/${PREFIX}/${DISTRIBUTION}"
