#!/bin/sh -e

ENVIRONMENT="${1}"

if [ "${ENVIRONMENT}" = "" ]; then
    echo "Usage: ${0} ENVIRONMENT"
    echo 'Environments: development, staging, production'

    exit 1
fi

# TODO: Check if already published: curl https://pypi.shiin.org/simple/python-skeleton/

if [ "${ENVIRONMENT}" = development ]; then
    twine upload build/*.whl --repository development
elif [ "${ENVIRONMENT}" = staging ]; then
    twine upload build/*.whl --repository testpypi
elif [ "${ENVIRONMENT}" = production ]; then
    twine upload build/*.whl
else
    echo "Unexpected environment: ${ENVIRONMENT}"
fi
