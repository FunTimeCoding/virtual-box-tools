# VirtualBoxTools

Helper scripts for running VirtualBox.


## Usage

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

Install the project from a local clone.

```sh
pip3 install --user --editable .
```

Install the project from GitHub.

```sh
pip3 install git+git://github.com/FunTimeCoding/virtual-box-tools.git
```

Uninstall the project.

```sh
pip3 uninstall virtual-box-tools
```


## Development

Run the main script without having to install the project.

```sh
PYTHONPATH=. bin/vbt
```

Install tools on OS X.

```sh
brew install shellcheck python3
```

Install tools on Debian Jessie.

```sh
apt-get install shellcheck python3-dev python3-pip python3-venv
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
