#!/bin/sh -e

vboxmanage list runningvms | awk -F'"' '{ print $2 }'
