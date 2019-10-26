#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../../../configuration/project.sh"

docker run --detach --publish 2222:22 --name ansible-ssh "${VENDOR_NAME_LOWER}/ansible-ssh"
WORKING_DIRECTORY=$(pwd)
docker run --interactive --tty --rm --volume "${WORKING_DIRECTORY}:/project-volume" --link ansible-ssh "${VENDOR_NAME_LOWER}/ansible-playbook" playbook.yaml
