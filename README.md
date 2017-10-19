# VirtualBoxTools

Tools for VirtualBox to simplify manual usage and automated integration.


## Setup

This section explains how to install and uninstall this project.

Install the project.

```sh
pip3 install git+https://git@github.com/FunTimeCoding/virtual-box-tools.git#egg=virtual-box-tools
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

This section explains how to use this project.

Run the main program.

```sh
bin/vbt
```

Show help.

```sh
bin/vbt --help
bin/vbt host --help
bin/vbt service --help
```


## Development

This section explains commands to help the development of this project.

Configure Git on Windows before cloning. This avoids problems with Vagrant and VirtualBox.

```sh
git config --global core.autocrlf input
```

Install the project from a clone.

```sh
./setup.sh
```

Run tests, style check and metrics.

```sh
./run-tests.sh
./run-style-check.sh
./run-metrics.sh
```

Build the project.

```sh
./build.sh
```

Run VirtualBox commands as a different user.

```sh
sudo -u virtualbox vboxmanage showvminfo --machinereadable ${MACHINE_NAME}
```

Send a request to the web service.

```sh
curl --silent --header 'Authorization: Token example' localhost:5000/host
curl --silent --header 'Authorization: Token example' --header 'Content-Type: application/json' --request POST --data '{"name": "foo"}' localhost:5000/host
```
