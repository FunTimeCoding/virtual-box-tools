#!/bin/sh -e

if [ "${1}" = --help ]; then
    echo "Usage: ${0} [--help|--delete-existing|--while-running]"
    echo "--delete-existing: Destroy the virtual machine and recreate it before the tests."
    echo "--while-running: Skip the destroy and create steps and assume the virtual machine is already running."

    exit 0
fi

DELETE_EXISTING=false
WHILE_RUNNING=false

if [ "${1}" = --delete-existing ]; then
    DELETE_EXISTING=true
    shift
fi

if [ "${1}" = --while-running ]; then
    WHILE_RUNNING=true
    shift
fi

if [ "${WHILE_RUNNING}" = false ]; then
    if [ "${DELETE_EXISTING}" = true ]; then
        vagrant destroy --force
    else
        vagrant status | grep 'not created' > /dev/null 2>&1 && EXPECTED_STATE=true || EXPECTED_STATE=false

        if [ "${EXPECTED_STATE}" = false ]; then
            echo "The status of the virtual machine must be 'not created'."

            exit 1
        fi
    fi

    script/vagrant/create.sh
fi

ADDRESS=$(vagrant ssh -c "ip addr list eth1 | grep 'inet ' | cut -d ' ' -f6 | cut -d / -f1" 2> /dev/null | tr -d '\r')
A_TEST_FAILED=false

echo "Test from outside if the SSH daemon is listening for network connections."
nc -z "${ADDRESS}" 22 && NETCAT=true || NETCAT=false

if [ "${NETCAT}" = false ]; then
    A_TEST_FAILED=true
    echo Fail
fi

echo "Test from inside if the SSH daemon is listening for network connections."
NETSTAT=$(vagrant ssh --command 'sudo netstat -pant | grep sshd' 2>/dev/null | tr -d '\r')

if [ "${NETSTAT}" = '' ]; then
    A_TEST_FAILED=true
    echo Fail
fi


if [ "${WHILE_RUNNING}" = false ]; then
    vagrant halt
fi

if [ "${A_TEST_FAILED}" = true ]; then
    echo "At least one test failed."

    exit 1
fi
