#!/bin/sh -e

touch tmp/pypirc
chmod 600 tmp/pypirc
cat "${HOME}/.pypirc" > tmp/pypirc

vagrant up
