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

If VirtualBox runs as a different user, enable use of `sudo`.

```
sudo_user: vbox
```


## Setup

Install the repository in edit mode.

```sh
pip3 install --user --editable .
```

Uninstall the repository.

```sh
pip3 uninstall virtual-box-tools
```
