from getpass import getuser
from socket import getfqdn
from argparse import ArgumentDefaultsHelpFormatter
from sys import argv

import pwd
from virtual_box_tools.command_process import CommandProcess, \
    CommandFailed
from virtual_box_tools.custom_argument_parser import CustomArgumentParser
from virtual_box_tools.yaml_config import YamlConfig


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

    def create_host(
            self, name: str = '',
            cores: int = 1,
            memory: int = 4096,
            disk_size: int = 64,
            release: str = 'jessie'
    ):
        domain = getfqdn()
        print('Get root password')
        get_root_password_process = CommandProcess(
            arguments=['pass', 'host/' + name + '.' + domain + '/root'],
            sudo_user=self.sudo_user
        )
        root_password = get_root_password_process.get_standard_output()

        if root_password == '':
            print('Generate root password')
            generate_root_password_process = CommandProcess(
                arguments=[
                    'pass', 'generate',
                    'host/' + name + '.' + domain + '/root',
                    '--no-symbols', 14
                ],
                sudo_user=self.sudo_user
            )
            root_password = generate_root_password_process.standard_output()

        user = getuser()
        print('Get user password')
        get_user_password_process = CommandProcess(
            arguments=['pass', 'host/' + name + '.' + domain + '/' + user],
            sudo_user=self.sudo_user
        )
        user_password = get_user_password_process.get_standard_output()

        if user_password == '':
            print('Generate user password')
            generate_user_password_process = CommandProcess(
                arguments=[
                    'pass', 'generate',
                    'host/' + name + '.' + domain + '/' + user,
                    '--no-symbols', 14
                ],
                sudo_user=self.sudo_user
            )
            user_password = generate_user_password_process.standard_output()

        print(root_password)
        print(user_password)
        print(pwd.getpwnam(user)[4])

    def destroy_host(self, name: str = ''):
        pass


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
                    print(commands.create_host(
                        name=self.parsed_arguments.name
                    ))
                except CommandFailed as exception:
                    print(exception)
            elif 'destroy' in self.parsed_arguments:
                print('destroy stub')
            elif 'show' in self.parsed_arguments:
                try:
                    print(commands.get_host_information(
                        self.parsed_arguments.name
                    ))
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
