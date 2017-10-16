@echo off

if not exist tmp mkdir tmp

set /p NAME="Username: "
/* TODO: Make files with newlines. This would add a newline. echo %NAME% > tmp/user-name.txt */
echo|set /p=%NAME% > tmp/user-name.txt

set /p FULL_NAME="Full name: "
echo|set /p=%FULL_NAME% > tmp/full-name.txt

set /p DOMAIN="Domain: "
echo|set /p=%DOMAIN% > tmp/domain.txt
