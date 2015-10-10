# VirtualBoxTools

Helper scripts for running VirtualBox.


## Usage

Manage nodes using `node-config`.

```sh
./bin/node-config
```


## Configuration

Optionally specify the location of the `node file` in `~/.virtual-box-tools.yml`.

```
node_file: ~/srv/salt/pillar/node.sls
```


## Setup

### Debian

Install dependencies.

```sh
sudo apt-get install python3-yaml
```

Install the repository in edit mode.

```sh
pip-3.2 install --user --editable .
```

Uninstall the repository.

```sh
pip-3.2 uninstall virtual-box-tools
```


### OS X

Install the repository in edit mode.

```sh
pip3 install --user --editable .
```

Uninstall the repository.

```sh
pip3 uninstall virtual-box-tools
```
