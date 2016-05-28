# VirtualBoxTools

Tools for VirtualBox to simplify manual usage and automated integration.


## Setup

This section covers how to install and uninstall `VirtualBoxTools` as a user.

Install from GitHub.

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

This section contains notes for developers.

Install the project from a clone.

```sh
pip3 install --user --editable .
pip3 install --upgrade --user --requirement requirements.txt
```

Run main entry point without installing the project.

```sh
PYTHONPATH=. bin/vbt
```

Run code style check, metrics and tests.

```sh
./run-style-check.sh
./run-metrics.sh
./run-tests.sh
```

Build the project.

```sh
./build.sh
```

Run VirtualBox commands as a different user.

```sh
sudo -u virtualbox vboxmanage showvminfo --machinereadable ${MACHINE_NAME}
```


## Appendix

This section contains notes about the project skeleton.

- The `tests` directory is not called `test` because that package already exists.
- Dashes in the project name become underscores in Python.
