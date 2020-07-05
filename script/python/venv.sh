#!/bin/sh -e

if [ ! -d "${HOME}/venv" ]; then
    python3 -m venv "${HOME}/venv"
fi
