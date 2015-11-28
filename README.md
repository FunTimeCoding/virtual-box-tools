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

Install the repository and project dependencies.

```sh
pip3 install --upgrade --user --requirement requirements.txt
pip3 install --user --editable .
```

Uninstall the repository and library.

```sh
pip3 uninstall virtual_box_tools python_utility
```
