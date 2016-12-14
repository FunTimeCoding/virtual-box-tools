#!/bin/sh -e

LAST_PORT=$(netstat -ant4 | grep --only-matching --perl-regexp "90\d{2}" | tail -1)

if [ "${LAST_PORT}" = "" ]; then
    echo 9000
else
    echo "${LAST_PORT} + 1" | bc
fi
