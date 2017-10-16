@echo off

if not exist tmp mkdir tmp

echo "eth0" > tmp/ethernet-device.txt
echo nul > tmp/pypirc.txt

set /p USER_NAME="User name: "
:: TODO: Make files with newlines. This would add a newline.
::echo %USER_NAME% > tmp/user-name.txt
echo|set /p=%USER_NAME% > tmp/user-name.txt

set /p FULL_NAME="Full name: "
echo|set /p=%FULL_NAME% > tmp/full-name.txt

set /p DOMAIN="Domain: "
echo|set /p=%DOMAIN% > tmp/domain.txt

vagrant up
