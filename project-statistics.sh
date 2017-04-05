#!/bin/sh -e

FILE_COUNT=$(find . -type f | wc -l)
DIRECTORY_COUNT=$(find . -type d | wc -l)
echo "FILE_COUNT: ${FILE_COUNT}"
echo "DIRECTORY_COUNT: ${DIRECTORY_COUNT}"
