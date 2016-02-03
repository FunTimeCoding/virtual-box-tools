#!/bin/sh -e
# Experimental script to decide whether using flake8 is helpful.

flake8 --exclude=.pyvenv,.git,.idea,.tox --verbose --max-complexity 5
