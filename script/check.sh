#!/bin/sh -e

if [ "${1}" = --help ]; then
    echo "Usage: ${0} [--ci-mode]"

    exit 0
fi

CONCERN_FOUND=false
CONTINUOUS_INTEGRATION_MODE=false

if [ "${1}" = --ci-mode ]; then
    shift
    mkdir -p build/log
    CONTINUOUS_INTEGRATION_MODE=true
fi

MARKDOWN_FILES=$(find . -name '*.md')
BLACKLIST=""
DICTIONARY=en_US
mkdir -p tmp
cat documentation/dictionary/*.dic > tmp/combined.dic

for FILE in ${MARKDOWN_FILES}; do
    WORDS=$(hunspell -d "${DICTIONARY}" -p tmp/combined.dic -l "${FILE}" | sort | uniq)

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
    WORDS=$(hunspell -d "${DICTIONARY}" -p tmp/combined.dic -l -t "${FILE}")

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

SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    FIND='gfind'
else
    FIND='find'
fi

INCLUDE_FILTER='^.*(\/bin\/[a-z]*|\.py)$'
EXCLUDE_FILTER='^.*\/(build|tmp|\.git|\.vagrant|\.idea|\.venv|\.tox)\/.*$'

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    FILES=$(${FIND} . -name '*.sh' -regextype posix-extended ! -regex "${EXCLUDE_FILTER}" -printf '%P\n')

    for FILE in ${FILES}; do
        FILE_REPLACED=$(echo "${FILE}" | sed 's/\//-/g')
        shellcheck --format checkstyle "${FILE}" > "build/log/checkstyle-${FILE_REPLACED}.xml" || true
    done
else
    # shellcheck disable=SC2016
    SHELL_SCRIPT_CONCERNS=$(${FIND} . -name '*.sh' -regextype posix-extended ! -regex "${EXCLUDE_FILTER}" -exec sh -c 'shellcheck ${1} || true' '_' '{}' \;)

    if [ ! "${SHELL_SCRIPT_CONCERNS}" = "" ]; then
        CONCERN_FOUND=true
        echo "(WARNING) Shell script concerns:"
        echo "${SHELL_SCRIPT_CONCERNS}"
    fi
fi

EXCLUDE_FILTER_WITH_INIT='^.*\/((build|tmp|\.git|\.vagrant|\.idea|\.venv|\.tox)\/.*|__init__\.py)$'
# shellcheck disable=SC2016
EMPTY_FILES=$(${FIND} . -empty -regextype posix-extended ! -regex "${EXCLUDE_FILTER_WITH_INIT}")

if [ ! "${EMPTY_FILES}" = "" ]; then
    CONCERN_FOUND=true

    if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
        echo "${EMPTY_FILES}" > build/log/empty-files.txt
    else
        echo
        echo "(WARNING) Empty files:"
        echo
        echo "${EMPTY_FILES}"
    fi
fi

# shellcheck disable=SC2016
TO_DOS=$(${FIND} . -regextype posix-extended -type f -and ! -regex "${EXCLUDE_FILTER}" -exec sh -c 'grep -Hrn TODO "${1}" | grep -v "${2}"' '_' '{}' '${0}' \;)

if [ ! "${TO_DOS}" = "" ]; then
    if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
        echo "${TO_DOS}" > build/log/to-dos.txt
    else
        echo
        echo "(NOTICE) To dos:"
        echo
        echo "${TO_DOS}"
    fi
fi

# shellcheck disable=SC2016
SHELLCHECK_IGNORES=$(${FIND} . -regextype posix-extended -type f -and ! -regex "${EXCLUDE_FILTER}" -exec sh -c 'grep -Hrn "# shellcheck" "${1}" | grep -v "${2}"' '_' '{}' '${0}' \;)

if [ ! "${SHELLCHECK_IGNORES}" = "" ]; then
    if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
        echo "${SHELLCHECK_IGNORES}" > build/log/shellcheck-ignores.txt
    else
        echo
        echo "(NOTICE) Shellcheck ignores:"
        echo
        echo "${SHELLCHECK_IGNORES}"
    fi
fi

PYCODESTYLE_CONCERNS=$(pycodestyle --exclude=.git,.tox,.venv,__pycache__ --statistics .) || true

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    echo "${PYCODESTYLE_CONCERNS}" > build/log/pycodestyle.txt
else
    if [ ! "${PYCODESTYLE_CONCERNS}" = "" ]; then
        CONCERN_FOUND=true
        echo
        echo "(WARNING) PEP8 concerns:"
        echo
        echo "${PYCODESTYLE_CONCERNS}"
    fi
fi

PYTHON_FILES=$(${FIND} . -type f -regextype posix-extended -regex "${INCLUDE_FILTER}" -and ! -regex "${EXCLUDE_FILTER}")
RETURN_CODE=0
# shellcheck disable=SC2086
PYLINT_OUTPUT=$(pylint ${PYTHON_FILES}) || RETURN_CODE=$?
SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    TEE='gtee'
else
    TEE='tee'
fi

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    echo | "${TEE}" build/log/pylint.txt
    echo "(NOTICE) Pylint" | "${TEE}" --append build/log/pylint.txt
    echo "${PYLINT_OUTPUT}" | "${TEE}" --append build/log/pylint.txt
else
    echo
    echo "(NOTICE) Pylint"
    echo "${PYLINT_OUTPUT}"
fi

if [ ! "${RETURN_CODE}" = 0 ]; then
    echo "Pylint return code: ${RETURN_CODE}"
fi

if [ "${CONCERN_FOUND}" = true ]; then
    echo
    echo "Concern(s) of category WARNING found." >&2

    exit 2
fi
