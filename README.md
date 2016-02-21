# VirtualBoxTools

Helper scripts for running VirtualBox.


## Usage

This section explains how to use this project.

Manage hosts using `vbt`.

```sh
./bin/vbt
```


## Configuration

Optionally specify the location of the host config in `~/.virtual-box-tools.yml`.

```yml
host_file: ~/srv/salt/pillar/host.sls
```

If VirtualBox runs as a different user, enable use of `sudo`.

```yml
sudo_user: vbox
```


## Setup

This section explains how to install this project and how to include it in another.

Install the project from a local clone.

```sh
pip3 install --user --editable .
```

Install the project from GitHub.

```sh
pip3 install git+ssh://git@github.com/FunTimeCoding/virtual-box-tools.git#egg=virtual-box-tools
```

Uninstall the project.

```sh
pip3 uninstall virtual-box-tools
```

Require this repository in another projects `requirements.txt`.

```
git+ssh://git@github.com/FunTimeCoding/virtual-box-tools.git#egg=virtual-box-tools
```


## Development

This section explains how to use scripts that are intended to ease the development of this project.

Run the main script without installing the project.

```sh
PYTHONPATH=. bin/vbt
```

Install tools on Debian Jessie.

```sh
apt-get install shellcheck
```

Install tools on OS X.

```sh
brew install shellcheck
```

Install pip requirements.

```sh
pip3 install --upgrade --user --requirement requirements.txt
```

Run code style check, metrics and tests.

```sh
./run-style-check.sh
./run-metrics.sh
./run-tests.sh
```

Build the project like Jenkins.

```sh
./build.sh
```


## Skeleton details

* The `tests` directory is not called `test` because that package already exists.
* Dashes in the project name become underscores in Python.
