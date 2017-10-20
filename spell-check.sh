#!/bin/sh -e

if [ "${1}" = --help ]; then
    echo "Usage: ${0} [--ci-mode]"

    exit 0
fi

CONTINUOUS_INTEGRATION_MODE=false

if [ "${1}" = --ci-mode ]; then
    shift
    mkdir -p build/log
    CONTINUOUS_INTEGRATION_MODE=true
fi

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
MARKDOWN_FILES=$(find . -name '*.md')
BLACKLIST=""
DICTIONARY=en_US

for FILE in ${MARKDOWN_FILES}; do
    WORDS=$(hunspell -d "${DICTIONARY}" -p "${SCRIPT_DIRECTORY}/dict/virtual-box-tools.dic" -l "${FILE}" | sort | uniq)

    if [ ! "${WORDS}" = "" ]; then
        echo "${FILE}"

        for WORD in ${WORDS}; do
            BLACKLISTED=$(echo "${BLACKLIST}" | grep "${WORD}") || BLACKLISTED=false

            if [ "${BLACKLISTED}" = false ]; then
                if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
                    grep --line-number "${WORD}" "${FILE}"
                else
                    # The equals character is required.
                    grep --line-number --color=always "${WORD}" "${FILE}"
                fi
            else
                echo "Blacklisted word: ${WORD}"
            fi
        done

        echo
    fi
done

TEX_FILES=$(find . -name '*.tex')

for FILE in ${TEX_FILES}; do
    WORDS=$(hunspell -d "${DICTIONARY}" -p "${SCRIPT_DIRECTORY}/dict/virtual-box-tools.dic" -l -t "${FILE}")

    if [ ! "${WORDS}" = "" ]; then
        echo "${FILE}"

        for WORD in ${WORDS}; do
            STARTS_WITH_DASH=$(echo "${WORD}" | grep -q '^-') || STARTS_WITH_DASH=false

            if [ "${STARTS_WITH_DASH}" = false ]; then
                BLACKLISTED=$(echo "${BLACKLIST}" | grep "${WORD}") || BLACKLISTED=false

                if [ "${BLACKLISTED}" = false ]; then
                    if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
                        grep --line-number "${WORD}" "${FILE}"
                    else
                        # The equals character is required.
                        grep --line-number --color=always "${WORD}" "${FILE}"
                    fi
                else
                    echo "Skip blacklisted: ${WORD}"
                fi
            else
                echo "Skip invalid: ${WORD}"
            fi
        done

        echo
    fi
done
