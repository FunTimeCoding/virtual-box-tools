#!/bin/sh -e

if [ "${1}" = --help ]; then
    echo "Usage: ${0} [--ci-mode]"

    exit 0
fi

if [ "${GIT_BRANCH}" = '' ]; then
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
fi

if [ "${GIT_BRANCH}" = master ]; then
    echo "TODO: When to not host projects publicly? Introduce a setting in project.sh?"

    #if [ ! "${1}" = --ci-mode ]; then
    #    script/python/publish.sh production
    #fi

    #if [ "${SYSTEM}" = Linux ]; then
    #    script/debian/publish.sh
    #fi
else
    echo "TODO: Always publish to development?"
    #script/python/publish.sh development
    #script/python/publish.sh staging
fi
