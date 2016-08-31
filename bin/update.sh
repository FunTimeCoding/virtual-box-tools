#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
"${SCRIPT_DIRECTORY}"/stop-running-vms.sh
sudo service vboxweb-service stop
sleep 10
debian-update.sh
