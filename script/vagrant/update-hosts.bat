@echo off

vagrant ssh --command "/vagrant/script/vagrant/address.sh > /vagrant/tmp/address.txt"

set /p ADDRESS=<tmp\address.txt
set /p HOSTNAME=<tmp\hostname.txt
set /p DOMAIN=<tmp\domain.txt

set NEWLINE=^& echo.

findstr /v %HOSTNAME%.%DOMAIN% %WINDIR%\system32\drivers\etc\hosts>tmp\hosts.txt
echo %NEWLINE%^%ADDRESS% %HOSTNAME%.%DOMAIN%>>tmp\hosts.txt
copy /b/v/y tmp\hosts.txt %WINDIR%\System32\drivers\etc\hosts
