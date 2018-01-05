@echo off

if not exist tmp mkdir tmp

echo eth0> tmp/ethernet-device.txt
copy /y nul "tmp/pypirc.txt"

set /p USER_NAME="User name: "
echo %USER_NAME%> tmp/user-name.txt

set /p FULL_NAME="Full name: "
echo %FULL_NAME%> tmp/full-name.txt

set /p DOMAIN="Domain: "
echo %DOMAIN%> tmp/domain.txt

vagrant up
pause
