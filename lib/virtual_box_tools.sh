#!/bin/sh -e

CONFIGURATION=''

while true; do
    case ${1} in
        --help)
            echo "Global usage: ${0} [--help][--configuration CONFIGURATION]"

            if command -v usage > /dev/null; then
                usage
            fi

            exit 0
            ;;
        --configuration)
            CONFIGURATION=${2-}
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

OPTIND=1

if [ "${CONFIGURATION}" = '' ]; then
    CONFIGURATION="${HOME}/.virtual-box-tools.yaml"
fi

CONFIGURATION=$(realpath "${CONFIGURATION}")

if [ -f "${CONFIGURATION}" ]; then
    DIRECTORY=$(dirname "${0}")
    SCRIPT_DIRECTORY=$(cd "${DIRECTORY}" || exit 1; pwd)
    SHYAML="${SCRIPT_DIRECTORY}/../.venv/bin/shyaml"
    SUDO_USER=$(${SHYAML} get-value sudo_user < "${CONFIGURATION}" 2> /dev/null || true)
else
    CONFIGURATION=''
fi

if [ "${SUDO_USER}" = '' ]; then
    VBOXMANAGE=vboxmanage
else
    SUDO="sudo -u ${SUDO_USER}"
    VBOXMANAGE="${SUDO} vboxmanage"
    export SUDO
fi

export VBOXMANAGE
