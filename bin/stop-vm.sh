#!/bin/sh -e

FORCE=false
WAIT=false

while true; do
    case ${1} in
        --force)
            FORCE=true
            shift
            ;;
        --wait)
            WAIT=true
            shift
            ;;
        *)
            break
            ;;
    esac
done

if [ "${FORCE}" = true ]; then
    vbt host stop --name "${1}" --force
else
    if [ "${WAIT}" = true ]; then
        vbt host stop --name "${1}" --wait
    else
        vbt host stop --name "${1}"
    fi
fi
