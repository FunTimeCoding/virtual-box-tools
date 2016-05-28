#!/bin/sh -e

if [ "$(command -v shyaml || true)" = "" ]; then
    echo "Command not found: shyaml"

    exit 1
fi

if [ "$(command -v realpath || true)" = "" ]; then
    echo "Command not found: realpath"

    exit 1
fi

function_exists()
{
    declare -f -F "${1}" > /dev/null

    return $?
}

CONFIG="${HOME}/.virtual-box-tools.yml"

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

if [ -f "${CONFIG}" ]; then
    CONFIG=$(realpath "${CONFIG}")
    SUDO_USER=$(shyaml get-value sudo_user < "${CONFIG}" 2>/dev/null || true)
else
    CONFIG=""
fi

if [ "${SUDO_USER}" = "" ]; then
    VBOXMANAGE=vboxmanage
else
    SUDO="sudo -u ${SUDO_USER}"
    VBOXMANAGE="${SUDO} vboxmanage"
    export SUDO
fi

export VBOXMANAGE
