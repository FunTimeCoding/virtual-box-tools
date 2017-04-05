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


## Configuration

This section explains configuration options.

Specify the location of the host config in `~/.virtual-box-tools.yml`. This is optional.

```yml
host_file: ~/srv/salt/pillar/host.sls
```

If VirtualBox runs as a different user, enable use of `sudo`.

```yml
sudo_user: vbox
```


## Usage

This section explains how to use this project.

Show help.

```sh
vbt --help
vbt host --help
vbt service --help
```


## Development

This section explains commands to help the development of this project.

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
