#!/bin/sh -e

if [ ! -d .git ]; then
    echo "Must be in the project root."

    exit 1
fi

cp script/git/pre-commit.sh .git/hooks/pre-commit
cp script/git/pre-push.sh .git/hooks/pre-push
