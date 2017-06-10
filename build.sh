#!/bin/sh -e

if [ ! -d .venv ]; then
    python3 -m venv .venv
fi

# shellcheck source=/dev/null
. .venv/bin/activate

PACKAGES=$(pip3 list --outdated --format legacy 2> /dev/null | awk '{ print $1 }')

for PACKAGE in ${PACKAGES}; do
    pip3 install --upgrade "${PACKAGE}"
done

pip3 install --upgrade --requirement requirements.txt
pip3 install --upgrade .
./run-style-check.sh --ci-mode
#./run-metrics.sh --ci-mode
./run-tests.sh --ci-mode
