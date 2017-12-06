#!/bin/sh -e

sqlite3 tmp/user.sqlite "SELECT * FROM user"
