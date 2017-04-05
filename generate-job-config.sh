#!/bin/sh -e

# shellcheck disable=SC2016
jjm --locator https://github.com/FunTimeCoding/virtual-box-tools.git --build-command 'export PATH="${HOME}/opt/python-3.5.1/bin:${HOME}/.cabal/bin:${HOME}/.local/bin:/usr/local/bin:${PATH}"
./build.sh' > job.xml
