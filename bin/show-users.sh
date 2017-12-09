#!/bin/sh -e

sqlite3 "${HOME}/.virtual-box-tools/user.sqlite" "SELECT * FROM user"
