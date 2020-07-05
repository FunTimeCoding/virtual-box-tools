#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(
    cd "${DIRECTORY}" || exit 1
    pwd
)
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

FILES_EXCLUDE='^.*\/(build|tmp|vendor|node_modules|\.git|\.vagrant|\.idea|\.tox|__pycache__|[a-z_]+\.egg-info)\/.*$'
FILES=$(${FIND} . -type f -regextype posix-extended ! -regex "${FILES_EXCLUDE}" | ${WC} --lines)
DIRECTORIES_EXCLUDE='^.*\/(build|tmp|vendor|node_modules|\.git|\.vagrant|\.idea|\.tox|__pycache__)(\/.*)?$'
DIRECTORIES=$(${FIND} . -type d -regextype posix-extended ! -regex "${DIRECTORIES_EXCLUDE}" | ${WC} --lines)
INCLUDE='^.*\.py$'
CODE_EXCLUDE='^.*\/(build|tmp|vendor|node_modules|target|\.git|\.vagrant|\.idea|\.tox)\/.*$'
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
    LAST_ANALYSIS_EPOCH=0

    if [ -f "${HOME}/.static-analysis-tools.sh" ]; then
        # shellcheck source=/dev/null
        . "${HOME}/.static-analysis-tools.sh"

        OUTPUT_BEFORE=$(curl --silent --user "${SONAR_TOKEN}:" "${SONAR_SERVER}/api/measures/component?component=${PROJECT_NAME_DASH}&metricKeys=sqale_index&additionalFields=period")
        ERRORS=$(echo "${OUTPUT_BEFORE}" | jq --raw-output 'select(.errors)')

        if [ "${ERRORS}" = '' ]; then
            COMPONENT_KEY=$(echo "${OUTPUT_BEFORE}" | jq --raw-output '.component.key')
            LAST_ANALYSIS_ISO_DATE=$(curl --silent --user "${SONAR_TOKEN}:" "${SONAR_SERVER}/api/project_analyses/search?project=${COMPONENT_KEY}" | jq --raw-output '.analyses[0].date')
            LAST_ANALYSIS_EPOCH=$(date -d "${LAST_ANALYSIS_ISO_DATE}" "+%s")
        else
            echo "Error: ${OUTPUT_BEFORE}"
        fi

        sonar-scanner --define "sonar.projectKey=${PROJECT_NAME_DASH}" --define "sonar.sources=." --define "sonar.host.url=${SONAR_SERVER}" --define "sonar.login=${SONAR_TOKEN}" | "${TEE}" build/log/sonar-runner.log
    else
        echo "SonarQube configuration missing."

        exit 1
    fi

    for SECOND in $(seq 1 30); do
        OUTPUT_CURRENT=$(curl --silent --user "${SONAR_TOKEN}:" "${SONAR_SERVER}/api/measures/component?component=${PROJECT_NAME_DASH}&metricKeys=sqale_index,duplicated_blocks,duplicated_lines_density&additionalFields=period")
        MEASURE_COUNT=$(echo "${OUTPUT_CURRENT}" | jq --raw-output '.component.measures | length')

        if [ ! "${MEASURE_COUNT}" = 0 ]; then
            COMPONENT_KEY=$(echo "${OUTPUT_CURRENT}" | jq --raw-output '.component.key')
            CURRENT_ANALYSIS_ISO_DATE=$(curl --silent --user "${SONAR_TOKEN}:" "${SONAR_SERVER}/api/project_analyses/search?project=${COMPONENT_KEY}" | jq --raw-output '.analyses[0].date')

            if [ ! "${CURRENT_ANALYSIS_ISO_DATE}" = 'null' ]; then
                CURRENT_ANALYSIS_EPOCH=$(date -d "${CURRENT_ANALYSIS_ISO_DATE}" "+%s")

                if [ "${CURRENT_ANALYSIS_EPOCH}" -gt "${LAST_ANALYSIS_EPOCH}" ]; then
                    # New result found. Add newline after dots.
                    echo ''

                    break
                fi
            fi
        fi

        if [ "${SECOND}" = 30 ]; then
            echo "Timeout reached."

            exit 1
        else
            printf .
            sleep 1
        fi
    done

    CONCERN_FOUND=false
    SQALE_INDEX=$(echo "${OUTPUT_CURRENT}" | jq --raw-output '.component.measures[] | select(.metric == "sqale_index") | .value')

    if [ "${SQALE_INDEX}" -gt 0 ]; then
        CONCERN_FOUND=true
        echo "Warning: SQALE_INDEX ${SQALE_INDEX}"
    fi

    DUPLICATED_BLOCKS=$(echo "${OUTPUT_CURRENT}" | jq --raw-output '.component.measures[] | select(.metric == "duplicated_blocks") | .value')

    if [ "${DUPLICATED_BLOCKS}" -gt 0 ]; then
        CONCERN_FOUND=true
        echo "Warning: DUPLICATED_BLOCKS ${DUPLICATED_BLOCKS}"
    fi

    DUPLICATED_LINES_DENSITY=$(echo "${OUTPUT_CURRENT}" | jq --raw-output '.component.measures[] | select(.metric == "duplicated_lines_density") | .value')
    DUPLICATED_LINES_DENSITY_CEIL=$(python3 -c "from math import ceil; print(ceil(${DUPLICATED_LINES_DENSITY}))")

    if [ "${DUPLICATED_LINES_DENSITY_CEIL}" -gt 0 ]; then
        CONCERN_FOUND=true
        echo "Warning: DUPLICATED_LINES_DENSITY ${DUPLICATED_LINES_DENSITY}"
    fi

    if [ "${CONCERN_FOUND}" = true ]; then
        echo
        echo "Concern(s) of category WARNING found." >&2

        exit 2
    fi
fi
