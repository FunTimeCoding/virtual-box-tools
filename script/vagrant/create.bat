@echo off
if not exist .venv python -m venv .venv

if not exist tmp mkdir tmp

if not exist tmp/bootstrap-salt.sh powershell -Command "Invoke-WebRequest https://bootstrap.saltstack.com -OutFile tmp/bootstrap-salt.sh"

copy configuration\minion.yaml tmp\salt\minion.conf

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
