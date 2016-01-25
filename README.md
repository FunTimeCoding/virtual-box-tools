# VirtualBoxTools

Helper scripts for running VirtualBox.


## Usage

Manage nodes using `node-config`.

```sh
./bin/node-config
```


## Configuration

Optionally specify the location of the `node file` in `~/.virtual-box-tools.yml`.

```yml
node_file: ~/srv/salt/pillar/node.sls
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
PYTHONPATH=. bin/node-config
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

Build project like Jenkins.

```sh
./build.sh
```


## Skeleton details

* The reason why the `tests` directory is not called `test` is because a package named `test` exists.
* The main source code directory is the same name as the package in python packages.
* Dashes in project names become underscores in python code. They are still legit.
