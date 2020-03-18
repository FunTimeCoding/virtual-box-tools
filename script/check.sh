#!/bin/sh -e

DIRECTORY=$(dirname "${0}")
SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
# shellcheck source=/dev/null
. "${SCRIPT_DIRECTORY}/../configuration/project.sh"

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

SYSTEM=$(uname)

if [ "${SYSTEM}" = Darwin ]; then
    FIND='gfind'
    UNIQ='guniq'
    SED='gsed'
else
    FIND='find'
    UNIQ='uniq'
    SED='sed'
fi

MARKDOWN_FILES=$(${FIND} . -regextype posix-extended -name '*.md' -regex "${INCLUDE_FILTER}" -printf '%P\n')
DICTIONARY=en_US
mkdir -p tmp

if [ -d documentation/dictionary ]; then
    cat documentation/dictionary/*.dic > tmp/combined.dic
else
    touch tmp/combined.dic
fi

for FILE in ${MARKDOWN_FILES}; do
    WORDS=$(hunspell -d "${DICTIONARY}" -p tmp/combined.dic -l "${FILE}" | sort | ${UNIQ})

    if [ ! "${WORDS}" = '' ]; then
        echo "${FILE}"

        for WORD in ${WORDS}; do
            if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
                grep --line-number "${WORD}" "${FILE}"
            else
                # The equals character is required.
                grep --line-number --color=always "${WORD}" "${FILE}"
            fi
        done

        echo
    fi
done

TEX_FILES=$(${FIND} . -regextype posix-extended -name '*.tex' -regex "${INCLUDE_FILTER}" -printf '%P\n')

for FILE in ${TEX_FILES}; do
    WORDS=$(hunspell -d "${DICTIONARY}" -p tmp/combined.dic -l -t "${FILE}")

    if [ ! "${WORDS}" = '' ]; then
        echo "${FILE}"

        for WORD in ${WORDS}; do
            STARTS_WITH_DASH=$(echo "${WORD}" | grep -q '^-') || STARTS_WITH_DASH=false

            if [ "${STARTS_WITH_DASH}" = false ]; then
                if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
                    grep --line-number "${WORD}" "${FILE}"
                else
                    # The equals character is required.
                    grep --line-number --color=always "${WORD}" "${FILE}"
                fi
            else
                echo "Skip invalid: ${WORD}"
            fi
        done

        echo
    fi
done

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    FILES=$(${FIND} . -regextype posix-extended -name '*.sh' -regex "${INCLUDE_FILTER}" -printf '%P\n')

    for FILE in ${FILES}; do
        FILE_REPLACED=$(echo "${FILE}" | ${SED} 's/\//-/g')
        shellcheck --format checkstyle "${FILE}" > "build/log/checkstyle-${FILE_REPLACED}.xml" || true
    done
fi

# shellcheck disable=SC2016
SHELL_SCRIPT_CONCERNS=$(${FIND} . -regextype posix-extended -name '*.sh' -regex "${INCLUDE_FILTER}" -exec sh -c 'shellcheck ${1} || true' '_' '{}' \;)

if [ ! "${SHELL_SCRIPT_CONCERNS}" = '' ]; then
    CONCERN_FOUND=true
    echo "[WARNING] Shell script concerns:"
    echo "${SHELL_SCRIPT_CONCERNS}"
fi

# shellcheck disable=SC2016
EMPTY_FILES=$(${FIND} . -regextype posix-extended -type f -empty -regex "${INCLUDE_FILTER}")

if [ ! "${EMPTY_FILES}" = '' ]; then
    CONCERN_FOUND=true
    echo
    echo "[WARNING] Empty files:"
    echo
    echo "${EMPTY_FILES}"
fi

# shellcheck disable=SC2016
TO_DOS=$(${FIND} . -regextype posix-extended -type f -regex "${INCLUDE_FILTER}" -exec sh -c 'grep -Hrn TODO "${1}" | grep -v "${2}"' '_' '{}' '${0}' \;)

if [ ! "${TO_DOS}" = '' ]; then
    echo
    echo "[INFO] To dos:"
    echo
    echo "${TO_DOS}"
fi

DUPLICATE_WORDS=$(cat documentation/dictionary/** | ${SED} '/^$/d' | sort | ${UNIQ} -cd)

if [ ! "${DUPLICATE_WORDS}" = '' ]; then
    CONCERN_FOUND=true
    echo
    echo "[WARNING] Duplicate words:"
    echo "${DUPLICATE_WORDS}"
fi

# shellcheck disable=SC2016
SHELLCHECK_DISABLES=$(${FIND} . -regextype posix-extended -type f -regex "${INCLUDE_FILTER}" -exec sh -c 'grep -Hrn "# shellcheck disable" "${1}" | grep -v "${2}"' '_' '{}' '${0}' \;)

if [ ! "${SHELLCHECK_DISABLES}" = '' ]; then
    echo
    echo "[INFO] Shellcheck disables:"
    echo
    echo "${SHELLCHECK_DISABLES}"
fi

PYCODESTYLE_CONCERNS=$(pycodestyle --exclude=.git,.tox,.venv,__pycache__ --statistics .) || true

if [ ! "${PYCODESTYLE_CONCERNS}" = '' ]; then
    CONCERN_FOUND=true
    echo
    echo "[WARNING] PEP8 concerns:"
    echo
    echo "${PYCODESTYLE_CONCERNS}"
fi

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    echo "${PYCODESTYLE_CONCERNS}" > build/log/pycodestyle.txt
fi

PYTHON_FILES=$(${FIND} . -regextype posix-extended -type f -name '*.py' -regex "${INCLUDE_FILTER}" ! -regex "${INCLUDE_STILL_FILTER}")
RETURN_CODE=0
# shellcheck disable=SC2086
PYLINT_OUTPUT=$(pylint ${PYTHON_FILES}) || RETURN_CODE=$?
echo
echo "[NOTICE] Pylint report:"
echo "${PYLINT_OUTPUT}"

if [ "${CONTINUOUS_INTEGRATION_MODE}" = true ]; then
    echo "${PYLINT_OUTPUT}" > build/log/pylint.txt
fi

if [ ! "${RETURN_CODE}" = 0 ]; then
    echo "Pylint return code: ${RETURN_CODE}"
fi

if [ "${CONCERN_FOUND}" = true ]; then
    echo
    echo "Warning level concern(s) found." >&2

    exit 2
fi
