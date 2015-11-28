#!/bin/sh -e

if [ "$(command -v shyaml || true)" = "" ]; then
    echo "Command not found: shyaml"

    exit 1
fi

CONFIG=""
VERBOSE=false

function_exists()
{
    declare -f -F "${1}" > /dev/null

    return $?
}

while true; do
    case ${1} in
        -c|--config)
            CONFIG=${2-}
            shift 2
            ;;
        -h|--help)
            echo "Global usage: ${0} [-v|--verbose][-d|--debug][-h|--help][-c|--config CONFIG]"

            if function_exists usage; then
                usage
            fi

            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            echo "Verbose mode enabled."
            shift
            ;;
        -d|--debug)
            set -x
            shift
            ;;
        *)
            break
            ;;
    esac
done

OPTIND=1

if [ "${VERBOSE}" = true ]; then
    echo "find_config"
fi

if [ "${CONFIG}" = "" ]; then
    CONFIG="${HOME}/.virtual-box-tools.yml"
fi

REALPATH_EXISTS=$(command -v realpath 2>&1)

if [ ! "${REALPATH_EXISTS}" = "" ]; then
    REALPATH_CMD="realpath"
else
    REALPATH_EXISTS=$(command -v grealpath 2>&1)

    if [ ! "${REALPATH_EXISTS}" = "" ]; then
        REALPATH_CMD="grealpath"
    else
        echo "Required tool (g)realpath not found."

        exit 1
    fi
fi

if [ -f "${CONFIG}" ]; then
    CONFIG=$(${REALPATH_CMD} "${CONFIG}")
else
    CONFIG=""
fi

if [ "${VERBOSE}" = true ]; then
    echo "load_config"
fi

if [ ! "${CONFIG}" = "" ]; then
    SUDO_USER=$(shyaml get-value "sudo_user" < "${CONFIG}" 2>/dev/null || true)
fi

if [ "${VERBOSE}" = true ]; then
    echo "define_library_variables"
fi

if [ ! "${SUDO_USER}" = "" ]; then
    MANAGE_COMMAND="sudo -u ${SUDO_USER} vboxmanage"
else
    MANAGE_COMMAND="vboxmanage"
fi
