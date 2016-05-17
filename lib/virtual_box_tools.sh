#!/bin/sh -e

if [ "$(command -v shyaml || true)" = "" ]; then
    echo "Command not found: shyaml"

    exit 1
fi

function_exists()
{
    declare -f -F "${1}" > /dev/null

    return $?
}

while true; do
    case ${1} in
        --help)
            echo "Global usage: ${0} [--help][--config CONFIG]"

            if function_exists usage; then
                usage
            fi

            exit 0
            ;;
        --config)
            CONFIG=${2-}
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

OPTIND=1

if [ "${CONFIG}" = "" ]; then
    CONFIG="${HOME}/.virtual-box-tools.yml"
fi

REALPATH_EXISTS=$(command -v realpath 2>&1)

if [ ! "${REALPATH_EXISTS}" = "" ]; then
    REALPATH=realpath
else
    REALPATH_EXISTS=$(command -v grealpath 2>&1)

    if [ ! "${REALPATH_EXISTS}" = "" ]; then
        REALPATH=grealpath
    else
        echo "Required tool (g)realpath not found."

        exit 1
    fi
fi

if [ -f "${CONFIG}" ]; then
    CONFIG=$(${REALPATH} "${CONFIG}")
else
    CONFIG=""
fi

if [ ! "${CONFIG}" = "" ]; then
    SUDO_USER=$(shyaml get-value sudo_user < "${CONFIG}" 2>/dev/null || true)
fi

if [ ! "${SUDO_USER}" = "" ]; then
    MANAGE_COMMAND="sudo -u ${SUDO_USER} vboxmanage"
else
    MANAGE_COMMAND=vboxmanage
fi

export MANAGE_COMMAND
