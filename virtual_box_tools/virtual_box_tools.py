from getpass import getuser
from socket import getfqdn
from argparse import ArgumentDefaultsHelpFormatter
from os import name as os_name, umask, makedirs
from os.path import expanduser, exists
from sys import exit as system_exit, argv
from sys import platform
import tarfile
import sqlite3
import string
import random
import urllib.request
import shutil

from virtual_box_tools.command_process import CommandProcess, \
    CommandFailed
from virtual_box_tools.custom_argument_parser import CustomArgumentParser
from virtual_box_tools.yaml_config import YamlConfig

if 'nt' == os_name:
    import virtual_box_tools.windows_password_database as pwd
else:
    import pwd


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
        return CommandProcess(
            arguments=['vboxmanage', 'guestproperty', 'enumerate', name],
            sudo_user=self.sudo_user
        ).get_standard_output()

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
            cores: int = 1,
            memory: int = 4096,
            disk_size: int = 64,
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

        disk_path = home_directory + '/VirtualBox VMs/' + name + '/' + name + '.vdi'
        disk_size_in_megabytes = disk_size * 1024
        CommandProcess(
            arguments=[
                'vboxmanage', 'createmedium', 'disk',
                '--filename', disk_path,
                '--size', str(disk_size_in_megabytes)
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
            CommandProcess(
                arguments=[
                    'rm', '-rf', trivial_directory,
                ],
                sudo_user=self.sudo_user
            )

        CommandProcess(
            arguments=[
                'mkdir', '-p', trivial_directory,
            ],
            sudo_user=self.sudo_user
        )
        open_archive = tarfile.open(archive, 'r:gz')
        open_archive.extractall(trivial_directory)

    def destroy_host(self, name: str):
        CommandProcess(
            arguments=['vboxmanage', 'unregistervm', name, '--delete'],
            sudo_user=self.sudo_user
        )

    def get_host_state(self, name: str):
        return CommandProcess(
            arguments=['vboxmanage', 'showvminfo', '--machinereadable', name],
            sudo_user=self.sudo_user
        ).get_standard_output()


class VirtualBoxTools:
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
                    commands.create_host(name=self.parsed_arguments.name)
                except CommandFailed as exception:
                    print(exception)
            elif 'destroy' in self.parsed_arguments:
                try:
                    commands.destroy_host(name=self.parsed_arguments.name)
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

        list_parser = host_subparsers.add_parser('list', help='list hosts')
        list_parser.add_argument('list', action='store_true')
