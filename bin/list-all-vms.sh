#!/bin/sh -e

vboxmanage list vms | awk -F'"' '{ print $2 }'
