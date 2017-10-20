# VirtualBoxTools

Tools for VirtualBox to simplify manual usage and automated integration.


## Setup

This section explains how to install and uninstall the project.

Install the project.

```sh
pip3 install git+https://git@github.com/FunTimeCoding/virtual-box-tools.git#egg=virtual-box-tools
pip3 install -i https://testpypi.python.org/pypi virtual-box-tools
```

Uninstall the project.

```sh
pip3 uninstall virtual-box-tools
```

Configuration file location: ~/.virtual-box-tools.yaml

Optional: Use a host configuration from a different location.

```yml
host_file: ~/srv/salt/pillar/host.sls
```

Optional: Run virtual machines as a different user.

```yml
sudo_user: vbox
```


## Usage

This section explains how to use the project.

Run the program.

```sh
vbt
```

Show help.

```sh
vbt --help
vbt host --help
vbt service --help
```

Create a host.

```sh
vbt host create --name example
```

Destroy a host.

```sh
vbt host destroy --name example
```

Run the web service.

```sh
vbt-web-service
```


## Development

This section explains how to improve the project.

Configure Git on Windows before cloning. This avoids problems with Vagrant and VirtualBox.

```sh
git config --global core.autocrlf input
```

Build the project. This installs dependencies.

```sh
./build.sh
```

Run tests, style check and spell check.

```sh
./spell-check.sh
./style-check.sh
./tests.sh
```

Build the package.

```sh
./package.sh
```

Install the experimental Debian package.

```sh
sudo dpkg --install build/python3-virtual-box-tools_0.1.0-1_all.deb
```

Show files the package installed.

```sh
dpkg-query --listfiles python3-virtual-box-tools
```

Run VirtualBox commands as a different user.

```sh
sudo -u virtualbox vboxmanage showvminfo --machinereadable ${MACHINE_NAME}
```

Send a request to the web service.

```sh
curl --silent --header 'Authorization: Token example' localhost:5000/host
curl --silent --header 'Authorization: Token example' --header 'Content-Type: application/json' --request POST --data '{"name": "example"}' localhost:5000/host
curl --silent --header 'Authorization: Token example' --request DELETE localhost:5000/host/example
```

Show user entries.

```sh
sqlite3 user.sqlite "SELECT * FROM user"
```
