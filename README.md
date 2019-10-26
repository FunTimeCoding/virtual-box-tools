# VirtualBoxTools

Tools for VirtualBox to simplify manual usage and automated integration.


## Setup

Install project dependencies:

```sh
script/setup.sh
```

Install pip package from GitHub:

```sh
pip3 install git+https://git@github.com/FunTimeCoding/virtual-box-tools.git#egg=virtual-box-tools
```

Install pip package from DevPi:

```sh
pip3 install -i https://testpypi.python.org/pypi virtual-box-tools
```

Uninstall package:

```sh
pip3 uninstall virtual-box-tools
```

Configuration file location: ~/.virtual-box-tools.yaml

(Optional) Use a host configuration from a different location:

```yml
host_file: ~/srv/salt/pillar/host.sls
```

Optional: Run virtual machines as a different user:

```yml
sudo_user: vbox
```


## Usage

Run the main program:

```sh
bin/vbt
```

Run the main program inside the container:

```sh
docker run -it --rm funtimecoding/virtual-box-tools
```

Show help:

```sh
vbt --help
vbt host --help
```

Create a host:

```sh
vbt host create --name example
```

Create a host and connect it to a bridge interface:

```sh
vbt host create --name example --bridge-interface en0
```

Destroy a host:

```sh
vbt host destroy --name example
```

Run the web service:

```sh
vbt-web-service
```

Show users:

```sh
bin/show-users.sh
```


## Development

Configure Git on Windows before cloning:

```sh
git config --global core.autocrlf input
```

Install NFS plugin for Vagrant on Windows:

```bat
vagrant plugin install vagrant-winnfsd
```

Create the development virtual machine on Linux and Darwin:

```sh
script/vagrant/create.sh
```

Create the development virtual machine on Windows:

```bat
script\vagrant\create.bat
```

Run tests, style check and metrics:

```sh
script/test.sh [--help]
script/check.sh [--help]
script/measure.sh [--help]
```

Build project:

```sh
script/build.sh
```

Install Debian package:

```sh
sudo dpkg --install build/python3-virtual-box-tools_0.1.0-1_all.deb
```

Show files the package installed:

```sh
dpkg-query --listfiles python3-virtual-box-tools
```

Run the web service in a virtual environment:

```sh
script/start.sh
```

Run VirtualBox commands as a different user:

```sh
sudo -u virtualbox vboxmanage showvminfo --machinereadable ${MACHINE_NAME}
```

Send a request to the web service:

```sh
curl --silent --header 'Authorization: Token example' localhost:5000/host
curl --silent --header 'Authorization: Token example' --header 'Content-Type: application/json' --request POST --data '{"name": "example"}' localhost:5000/host
curl --silent --header 'Authorization: Token example' --request DELETE localhost:5000/host/example
```
