#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../configuration/project.sh"

if [ "${1}" = --help ]; then
    echo "Usage: ${0} [--ci-mode]"

    exit 0
fi

SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    WC='gwc'
    FIND='gfind'
else
    WC='wc'
    FIND='find'
fi

FILES_EXCLUDE='^.*\/(build|tmp|vendor|node_modules|\.git|\.vagrant|\.idea|\.venv|\.tox|__pycache__|[a-z_]+\.egg-info)\/.*$'
FILES=$(${FIND} . -type f -regextype posix-extended ! -regex "${FILES_EXCLUDE}" | ${WC} --lines)
DIRECTORIES_EXCLUDE='^.*\/(build|tmp|vendor|node_modules|\.git|\.vagrant|\.idea|\.venv|\.tox|__pycache__)(\/.*)?$'
DIRECTORIES=$(${FIND} . -type d -regextype posix-extended ! -regex "${DIRECTORIES_EXCLUDE}" | ${WC} --lines)
INCLUDE='^.*\.py$'
# TODO: Extract .venv, .tox and maybe __pycache_ and .egg-info into EXCLUDE_PYTHON variables?
CODE_EXCLUDE='^.*\/(build|tmp|vendor|node_modules|\.git|\.vagrant|\.idea|\.venv|\.tox)\/.*$'
CODE_EXCLUDE_JAVA_SCRIPT='^\.\/web/main\.js$'
CODE=$(${FIND} . -type f -regextype posix-extended -regex "${INCLUDE}" -and ! -regex "${CODE_EXCLUDE}" -and ! -regex "${CODE_EXCLUDE_JAVA_SCRIPT}" | xargs cat)
LINES=$(echo "${CODE}" | ${WC} --lines)
NON_BLANK_LINES=$(echo "${CODE}" | grep --invert-match --regexp '^$' | ${WC} --lines)
echo "FILES: ${FILES}"
echo "DIRECTORIES: ${DIRECTORIES}"
echo "LINES: ${LINES}"
echo "NON_BLANK_LINES: ${NON_BLANK_LINES}"

if [ "${1}" = --ci-mode ]; then
    shift

    if [ "${SYSTEM}" = Darwin ]; then
        TEE='gtee'
    else
        TEE='tee'
    fi

    mkdir -p build/log

    if [ -f "${HOME}/.sonar-qube-tools.sh" ]; then
        # shellcheck source=/dev/null
        . "${HOME}/.sonar-qube-tools.sh"
        sonar-scanner "-Dsonar.projectKey=${PROJECT_NAME_DASH}" -Dsonar.sources=. "-Dsonar.host.url=${SONAR_SERVER}" "-Dsonar.login=${SONAR_TOKEN}" '-Dsonar.exclusions=build/**,tmp/**' | "${TEE}" build/log/sonar-runner.log
    else
        echo "SonarQube configuration missing."

        exit 1
    fi

    CONCERN_FOUND=false
    SQALE_INDEX=$(curl --silent --user "${SONAR_TOKEN}:" "${SONAR_SERVER}/api/measures/component_tree?component=${PROJECT_NAME_DASH}&metricKeys=sqale_index" | jq --raw-output '.baseComponent.measures[].value')
    echo "SQALE_INDEX: ${SQALE_INDEX}"

    if [ ! "${SQALE_INDEX}" = 0 ]; then
        CONCERN_FOUND=true
        echo "Warning: SQALE_INDEX exceeded"
    fi

    DUPLICATED_BLOCKS=$(curl --silent --user "${SONAR_TOKEN}:" "${SONAR_SERVER}/api/measures/component_tree?component=${PROJECT_NAME_DASH}&metricKeys=duplicated_blocks" | jq --raw-output '.baseComponent.measures[].value')
    echo "DUPLICATED_BLOCKS: ${DUPLICATED_BLOCKS}"

    if [ ! "${DUPLICATED_BLOCKS}" = 0 ]; then
        CONCERN_FOUND=true
        echo "Warning: DUPLICATED_BLOCKS exceeded"
    fi

    DUPLICATED_LINES_DENSITY=$(curl --silent --user "${SONAR_TOKEN}:" "${SONAR_SERVER}/api/measures/component_tree?component=${PROJECT_NAME_DASH}&metricKeys=duplicated_lines_density" | jq --raw-output '.baseComponent.measures[].value')
    echo "DUPLICATED_LINES_DENSITY: ${DUPLICATED_LINES_DENSITY}"

    if [ ! "${DUPLICATED_LINES_DENSITY}" = 0.0 ]; then
        CONCERN_FOUND=true
        echo "Warning: DUPLICATED_LINES_DENSITY exceeded"
    fi

    if [ "${CONCERN_FOUND}" = true ]; then
        echo
        echo "Concern(s) of category WARNING found." >&2

        exit 2
    fi
fi
