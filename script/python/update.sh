#!/bin/sh -e

if [ ! -d .venv ]; then
    python3 -m venv .venv
fi

. .venv/bin/activate
# Update pip first before even checking the list. List might fail on Stretch since the bundled pip is too old.
pip install --upgrade pip
pip list --outdated
pip install --upgrade --requirement requirements.txt
pip check
