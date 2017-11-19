from getpass import getuser
from socket import getfqdn
from argparse import ArgumentDefaultsHelpFormatter
from os import name as operating_system_name, umask, makedirs
from os.path import expanduser, exists
from sys import exit as system_exit, argv, platform, stderr
from time import sleep
import tarfile
import sqlite3
import string
import random
import urllib.request
import shutil

from virtual_box_tools.scan_code import ScanCode
from virtual_box_tools.command_process import CommandProcess, \
    CommandFailed
from virtual_box_tools.custom_argument_parser import CustomArgumentParser
from virtual_box_tools.yaml_config import YamlConfig

if 'nt' == operating_system_name:
    import virtual_box_tools.windows_password_database as pwd
else:
    import pwd


class VirtualBoxTools:
    DEFAULT_CORES = 1
    DEFAULT_MEMORY = 4096
    DEFAULT_DISK_SIZE = 64

    def __init__(self, arguments: list):
        self.parser = self.create_parser()
        self.parsed_arguments = self.parser.parse_args(arguments)
        config = YamlConfig('~/.virtual-box-tools.yaml')
        self.sudo_user = config.get('sudo_user')

    @staticmethod
    def main() -> int:
        return VirtualBoxTools(argv[1:]).run()

    def run(self) -> int:
        if 'host' in self.parsed_arguments:
            commands = Commands(self.sudo_user)

            if 'list' in self.parsed_arguments:
                print(commands.list_hosts())
            elif 'create' in self.parsed_arguments:
                try:
                    commands.create_host(
                        name=self.parsed_arguments.name,
                        cores=self.parsed_arguments.cores,
                        memory=self.parsed_arguments.memory,
                        disk_size=self.parsed_arguments.disk_size,
                        bridge_interface=self.parsed_arguments.bridge_interface
                    )
                except CommandFailed as exception:
                    print(exception)
            elif 'destroy' in self.parsed_arguments:
                try:
                    commands.destroy_host(name=self.parsed_arguments.name)
                except CommandFailed as exception:
                    print(exception)
            elif 'stop' in self.parsed_arguments:
                try:
                    commands.stop_host(name=self.parsed_arguments.name)
                except CommandFailed as exception:
                    print(exception)
            elif 'show' in self.parsed_arguments:
                try:
                    print(
                        commands.get_host_information(
                            self.parsed_arguments.name
                        )
                    )
                except CommandFailed as exception:
                    if 'Could not find a registered machine named' \
                            in exception.get_standard_error():
                        print('Host not found.')
                    else:
                        print(exception)
            else:
                self.parser.print_help()
        else:
            self.parser.print_help()

        return 0

    @staticmethod
    def create_parser() -> CustomArgumentParser:
        parser = CustomArgumentParser(
            description='Wrapper around VirtualBox to simplify operations',
            formatter_class=ArgumentDefaultsHelpFormatter
        )
        subparsers = parser.add_subparsers()
        VirtualBoxTools.add_host_parser(subparsers)

        return parser

    @staticmethod
    def add_host_parser(subparsers) -> None:
        host_parent = CustomArgumentParser(add_help=False)
        host_parser = subparsers.add_parser(
            'host',
            parents=[host_parent],
            help='manage hosts'
        )
        host_parser.add_argument('host', action='store_true')
        host_subparsers = host_parser.add_subparsers()

        create_parent = CustomArgumentParser(add_help=False)
        create_parent.add_argument('--name', required=True)
        create_parent.add_argument(
            '--cores',
            default=VirtualBoxTools.DEFAULT_CORES
        )
        create_parent.add_argument(
            '--memory',
            default=VirtualBoxTools.DEFAULT_MEMORY
        )
        create_parent.add_argument(
            '--disk-size',
            default=VirtualBoxTools.DEFAULT_DISK_SIZE
        )
        create_parent.add_argument('--bridge-interface')
        create_parser = host_subparsers.add_parser(
            'create',
            parents=[create_parent],
            help='create a host'
        )
        create_parser.add_argument('create', action='store_true')

        destroy_parent = CustomArgumentParser(add_help=False)
        destroy_parent.add_argument('--name', required=True)
        destroy_parser = host_subparsers.add_parser(
            'destroy',
            parents=[destroy_parent],
            help='destroy a host'
        )
        destroy_parser.add_argument('destroy', action='store_true')

        show_parent = CustomArgumentParser(add_help=False)
        show_parent.add_argument('--name', required=True)
        show_parser = host_subparsers.add_parser(
            'show',
            parents=[show_parent],
            help='show a host'
        )
        show_parser.add_argument('show', action='store_true')

        stop_parent = CustomArgumentParser(add_help=False)
        stop_parent.add_argument('--name', required=True)
        stop_parser = host_subparsers.add_parser(
            'stop',
            parents=[stop_parent],
            help='stop a host'
        )
        stop_parser.add_argument('stop', action='store_true')

        list_parser = host_subparsers.add_parser('list', help='list hosts')
        list_parser.add_argument('list', action='store_true')


class Commands:
    def __init__(self, sudo_user: str):
        self.sudo_user = sudo_user

    def list_hosts(self) -> []:
        hosts = []

        for line in CommandProcess(
                arguments=['vboxmanage', 'list', 'vms'],
                sudo_user=self.sudo_user
        ).get_standard_output().splitlines():
            hosts += [{'name': line.split(' ')[0][1:-1]}]

        return hosts

    def get_host_information(self, name: str) -> []:
        # TODO: Filter virtual and hardware addresses out.
        # return CommandProcess(
        #     arguments=['vboxmanage', 'guestproperty', 'enumerate', name],
        #     sudo_user=self.sudo_user
        # ).get_standard_output()
        return self.get_host_state(name)

    def generate_password(self):
        chars = string.ascii_uppercase + string.ascii_lowercase + string.digits

        return ''.join(random.choice(chars) for x in range(14))

    def get_password_sqlite(self, user: str, name: str, domain: str) -> str:
        old_mask = umask(0o077)
        connection = sqlite3.connect('tmp/user.sqlite')
        umask(old_mask)
        cursor = connection.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS user (
                user_name TEXT NOT NULL,
                host_name TEXT NOT NULL,
                domain_name TEXT NOT NULL,
                password TEXT NOT NULL
            )
        """)
        connection.commit()
        cursor.execute(
            'SELECT password FROM user'
            ' WHERE user_name = ?'
            ' AND host_name = ?'
            ' AND domain_name = ?',
            [user, name, domain]
        )
        result = cursor.fetchone()

        if result is None:
            password = self.generate_password()
            cursor.execute(
                'INSERT INTO user VALUES (?, ?, ?, ?)',
                [user, name, domain, password]
            )
            connection.commit()
        else:
            password = result[0]

        cursor.close()

        return password

    def get_password_pass(self, user: str, name: str, domain: str) -> str:
        password = ''

        try:
            get_password_process = CommandProcess(
                arguments=['pass', 'host/' + name + '.' + domain + '/' + user],
                sudo_user=self.sudo_user
            )
            password = get_password_process.get_standard_output()
        except CommandFailed as exception:
            if 'not in the password store.' in exception.get_standard_error():
                generate_password_process = CommandProcess(
                    arguments=[
                        'pass', 'generate',
                        'host/' + name + '.' + domain + '/' + user,
                        '--no-symbols', '14'
                    ],
                    sudo_user=self.sudo_user
                )
                password = generate_password_process.get_standard_output()
            else:
                print(exception)
                system_exit(1)

        return password

    def create_host(
            self, name: str,
            cores: int = VirtualBoxTools.DEFAULT_CORES,
            memory: int = VirtualBoxTools.DEFAULT_MEMORY,
            disk_size: int = VirtualBoxTools.DEFAULT_DISK_SIZE,
            bridge_interface: str = ''
    ):
        domain = getfqdn()
        root_password = self.get_password_sqlite(
            user='root',
            name=name,
            domain=domain
        )
        user = getuser()
        user_password = self.get_password_sqlite(
            user=user,
            name=name,
            domain=domain
        )
        CommandProcess(
            arguments=[
                'dt',
                '--hostname', name,
                '--domain', domain,
                '--root-password', root_password,
                '--user-name', user,
                '--user-password', user_password,
                '--user-real-name', pwd.getpwnam(user)[4],
                '--output-document', 'tmp/' + name + '.cfg'
            ],
            sudo_user=self.sudo_user
        )
        CommandProcess(
            arguments=[
                'vboxmanage', 'createvm',
                '--name', name,
                '--register',
                '--ostype', 'Debian_64'
            ],
            sudo_user=self.sudo_user
        )
        controller_name = 'SATA controller'
        CommandProcess(
            arguments=[
                'vboxmanage', 'storagectl', name,
                '--name', controller_name,
                '--add', 'sata'
            ],
            sudo_user=self.sudo_user
        )

        user_home = expanduser('~')

        if self.sudo_user == '':
            home_directory = user_home
        else:
            home_directory = '/home/' + self.sudo_user

        disk_path = home_directory + '/VirtualBox VMs' \
                                     '/' + name + '/' + name + '.vdi'
        CommandProcess(
            arguments=[
                'vboxmanage', 'createmedium', 'disk',
                '--filename', disk_path,
                '--size', str(disk_size * 1024)
            ],
            sudo_user=self.sudo_user
        )
        CommandProcess(
            arguments=[
                'vboxmanage', 'storageattach', name,
                '--storagectl',
                controller_name,
                '--port', '0',
                '--device', '0',
                '--type', 'hdd',
                '--medium', disk_path
            ],
            sudo_user=self.sudo_user
        )
        CommandProcess(
            arguments=[
                'vboxmanage', 'storageattach', name,
                '--storagectl',
                controller_name,
                '--port', '1',
                '--device', '0',
                '--type', 'dvddrive',
                '--medium', 'emptydrive'
            ],
            sudo_user=self.sudo_user
        )
        CommandProcess(
            arguments=[
                'vboxmanage', 'modifyvm', name,
                '--acpi', 'on',
                '--cpus', str(cores),
                '--memory', str(memory),
                '--vram', '16'
            ],
            sudo_user=self.sudo_user
        )

        temporary_directory = user_home + '/tmp'

        if not exists(temporary_directory):
            makedirs(temporary_directory)

        archive = temporary_directory + '/netboot.tar.gz'

        if not exists(archive):
            with urllib.request.urlopen(
                    'http://ftp.debian.org/debian/dists/stretch/main'
                    '/installer-amd64/current/images/netboot/netboot.tar.gz'
            ) as response, open(archive, 'wb') as out_file:
                shutil.copyfileobj(response, out_file)

        if platform == 'darwin':
            configuration_directory = home_directory + '/Library/VirtualBox'
        else:
            configuration_directory = home_directory + '/.config/VirtualBox'

        trivial_directory = configuration_directory + '/TFTP'

        if exists(trivial_directory):
            # Cover the Windows case because rm is not the same there.
            if self.sudo_user == '':
                shutil.rmtree(trivial_directory)
            else:
                CommandProcess(
                    arguments=[
                        'rm', '-rf', trivial_directory,
                    ],
                    sudo_user=self.sudo_user
                )

        # Cover the Windows case because mkdir is not the same there.
        if self.sudo_user == '':
            makedirs(trivial_directory)
        else:
            CommandProcess(
                arguments=[
                    'mkdir', '-p', trivial_directory,
                ],
                sudo_user=self.sudo_user
            )

        open_archive = tarfile.open(archive, 'r:gz')
        open_archive.extractall(trivial_directory)
        CommandProcess(
            arguments=[
                'vboxmanage', 'modifyvm', name,
                '--nic1', 'nat',
                '--boot1', 'net',
                '--nattftpfile1', '/pxelinux.0'
            ],
            sudo_user=self.sudo_user
        )
        CommandProcess(
            arguments=[
                'vboxmanage', 'startvm', name,
                '--type', 'headless'
            ],
            sudo_user=self.sudo_user
        )
        sleep(20)
        CommandProcess(
            arguments=[
                'vboxmanage', 'controlvm', name,
                'keyboardputscancode', '01', '81'
            ],
            sudo_user=self.sudo_user
        )
        sleep(1)

        if platform == 'darwin':
            interfaces = []

            for line in CommandProcess(
                    arguments=['networksetup', '-listallhardwareports']
            ).get_standard_output().splitlines():
                pass
                elements = line.split(':')

                if 'Device' == elements[0]:
                    interfaces += [elements[1].strip()]

            if len(interfaces) == 0:
                raise Exception('Could not determine first network interface.')

            address = CommandProcess(
                arguments=['ipconfig', '-getifaddr', interfaces[0]]
            ).get_standard_output()
        elif platform == 'linux':
            interfaces = []

            for line in CommandProcess(
                    arguments=['ip', '-o', 'link', 'show']
            ).get_standard_output().splitlines():
                elements = line.split(':')
                interface = elements[1].strip()

                if interface != 'lo':
                    interfaces += [interface]

            if len(interfaces) == 0:
                raise Exception('Could not determine first network interface.')

            address = CommandProcess(
                arguments=['ifdata', '-pa', interfaces[0]]
            ).get_standard_output()
        elif platform == 'windows':
            raise Exception('Not implemented yet')
        else:
            raise Exception('Unexpected platform: ' + platform)

        command = 'auto url=http://' + address + ':8000/' + name + '.cfg'
        for line in ScanCode.scan(command).splitlines():
            CommandProcess(
                arguments=[
                              'vboxmanage', 'controlvm', name,
                              'keyboardputscancode',
                          ] + line.split(' '),
                sudo_user=self.sudo_user
            )

        sleep(1)
        CommandProcess(
            arguments=[
                'vboxmanage', 'controlvm', name,
                'keyboardputscancode', '1c', '9c'
            ],
            sudo_user=self.sudo_user
        )

        while True:
            sleep(60)
            state = self.get_host_state(name)

            if 'running' == state:
                print('.', end='')
            else:
                break

        if bridge_interface == '':
            CommandProcess(
                arguments=[
                    'vboxmanage', 'modifyvm', name,
                    '--nic1', 'hostonly',
                    '--hostonlyadapter1', 'vboxnet0'
                ],
                sudo_user=self.sudo_user
            )
        else:
            CommandProcess(
                arguments=[
                    'vboxmanage', 'modifyvm', name,
                    '--nic1', 'bridged',
                    '--bridgeadapter1', bridge_interface
                ],
                sudo_user=self.sudo_user
            )

    # TODO: implement poweroff
    def stop_host(self, name: str):
        CommandProcess(
            arguments=['vboxmanage', 'controlvm', name, 'acpipowerbutton'],
            sudo_user=self.sudo_user
        )

    def destroy_host(self, name: str):
        CommandProcess(
            arguments=['vboxmanage', 'unregistervm', name, '--delete'],
            sudo_user=self.sudo_user
        )

    def get_host_state(self, name: str):
        output = CommandProcess(
            arguments=['vboxmanage', 'showvminfo', '--machinereadable', name],
            sudo_user=self.sudo_user
        ).get_standard_output()

        for line in output.splitlines():
            elements = line.split('=')

            if 'VMState' == elements[0]:
                return elements[1].replace('"', '')

        return 'unknown'
