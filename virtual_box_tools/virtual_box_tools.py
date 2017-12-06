from getpass import getuser
from socket import getfqdn
from argparse import ArgumentDefaultsHelpFormatter
from os import name as operating_system_name, umask, makedirs, chdir
from os.path import expanduser, exists, join, abspath, dirname
from sys import exit as system_exit, argv, platform, stderr
from time import sleep
import tarfile
import sqlite3
import string
import random
import urllib.request
import shutil
import http.server
import socketserver
import threading

import virtual_box_tools
from virtual_box_tools.scan_code import ScanCode
from virtual_box_tools.command_process import CommandProcess, \
    CommandFailed
from virtual_box_tools.custom_argument_parser import CustomArgumentParser
from virtual_box_tools.yaml_config import YamlConfig

if 'nt' == operating_system_name:
    import virtual_box_tools.windows_password_database as pwd
else:
    import pwd


class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    pass


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
                        bridge_interface=self.parsed_arguments.bridge_interface,
                        skip_preseed=self.parsed_arguments.skip_preseed,
                        graphical=self.parsed_arguments.graphical,
                        additions=self.parsed_arguments.additions
                    )
                except CommandFailed as exception:
                    print(exception)
            elif 'destroy' in self.parsed_arguments:
                try:
                    commands.destroy_host(name=self.parsed_arguments.name)
                except CommandFailed as exception:
                    print(exception)
            elif 'start' in self.parsed_arguments:
                try:
                    commands.start_host(
                        name=self.parsed_arguments.name,
                        graphical=self.parsed_arguments.graphical,
                        wait=self.parsed_arguments.wait
                    )
                except CommandFailed as exception:
                    print(exception)
            elif 'stop' in self.parsed_arguments:
                try:
                    commands.stop_host(
                        name=self.parsed_arguments.name,
                        force=self.parsed_arguments.force,
                        wait=self.parsed_arguments.wait
                    )
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
        create_parent.add_argument('--skip-preseed', action='store_true')
        create_parent.add_argument('--graphical', action='store_true')
        create_parent.add_argument('--additions', action='store_true')
        create_parent.add_argument('--bridge-interface', default='')
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

        start_parent = CustomArgumentParser(add_help=False)
        start_parent.add_argument('--name', required=True)
        start_parent.add_argument('--graphical', action='store_true')
        start_parent.add_argument('--wait', action='store_true')
        start_parser = host_subparsers.add_parser(
            'start',
            parents=[start_parent],
            help='start a host'
        )
        start_parser.add_argument('start', action='store_true')

        stop_parent = CustomArgumentParser(add_help=False)
        stop_parent.add_argument('--name', required=True)
        stop_parent.add_argument('--force', action='store_true')
        stop_parent.add_argument('--wait', action='store_true')
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
        return 'virtual address: ' + self.get_virtual_host_address(name) \
               + '\nphysical address: ' + self.get_physical_host_address(name) \
               + '\nstate: ' + self.get_host_state(name)

    @staticmethod
    def generate_password() -> str:
        chars = string.ascii_uppercase + string.ascii_lowercase + string.digits

        return ''.join(random.choice(chars) for x in range(14))

    def get_password_sqlite(self, user: str, name: str, domain: str) -> str:
        old_mask = umask(0o077)

        # TODO: Move this to ~/.virtual-box-tools
        if not exists('tmp'):
            makedirs('tmp')

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

    def wait_until_host_stops(self, name: str) -> None:
        while True:
            sleep(60)
            state = self.get_host_state(name)

            if 'running' == state:
                # Flush because the dots would not show up in some cases.
                print('.', end='', flush=True)
            else:
                print('')

                break

    def create_host(
            self, name: str,
            cores: int = VirtualBoxTools.DEFAULT_CORES,
            memory: int = VirtualBoxTools.DEFAULT_MEMORY,
            disk_size: int = VirtualBoxTools.DEFAULT_DISK_SIZE,
            bridge_interface: str = '',
            skip_preseed: bool = False,
            graphical: bool = False,
            additions: bool = False
    ) -> None:
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
        user_home = expanduser('~')
        temporary_directory = join(user_home, 'tmp')
        web_directory = join(temporary_directory, 'web')

        if not exists(web_directory):
            makedirs(web_directory)

        # TODO: Decide whether to create the preseed file in this project.
        # Do not use sudo for dt, because it would not be available in PATH.
        if skip_preseed is False:
            CommandProcess(
                arguments=[
                    'dt',
                    '--hostname', name,
                    '--domain', domain,
                    '--root-password', root_password,
                    '--user-name', user,
                    '--user-password', user_password,
                    '--user-real-name', pwd.getpwnam(user)[4],
                    '--output-document', join(web_directory, name + '.cfg')
                ]
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

        if self.sudo_user == '':
            home_directory = user_home
        else:
            home_directory = join('/home', self.sudo_user)

        disk_path = join(
            home_directory,
            'VirtualBox VMs',
            name,
            name + '.vdi'
        )
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
        self.attach_disc(
            name=name,
            controller_name=controller_name,
            medium='emptydrive'
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

        if not exists(temporary_directory):
            makedirs(temporary_directory)

        archive = join(temporary_directory, 'netboot.tar.gz')

        if not exists(archive):
            with urllib.request.urlopen(
                    'http://ftp.debian.org/debian/dists/stretch/main'
                    '/installer-amd64/current/images/netboot/netboot.tar.gz'
            ) as response, open(archive, 'wb') as out_file:
                shutil.copyfileobj(response, out_file)

        if platform == 'darwin':
            configuration_directory = join(
                home_directory,
                'Library',
                'VirtualBox'
            )
        else:
            configuration_directory = join(
                home_directory,
                '.config',
                'VirtualBox'
            )

        trivial_directory = join(configuration_directory, 'TFTP')

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

        # Use own extract program since tar would not be available on Windows.
        if self.sudo_user == '':
            open_archive = tarfile.open(archive, 'r:gz')
            open_archive.extractall(trivial_directory)
        else:
            extract_path = shutil.which('vbt-extract')
            CommandProcess(
                arguments=[extract_path, archive, trivial_directory],
                sudo_user=self.sudo_user
            )

        CommandProcess(
            arguments=[
                'vboxmanage', 'modifyvm', name,
                '--nic1', 'nat',
                '--boot1', 'net',
                '--nattftpfile1', '/pxelinux.0'
            ],
            sudo_user=self.sudo_user
        )

        start_arguments = ['vboxmanage', 'startvm', name]

        if graphical is False:
            start_arguments += ['--type', 'headless']

        CommandProcess(
            arguments=start_arguments,
            sudo_user=self.sudo_user
        )
        sleep(20)
        # Escape to enter menu.
        self.keyboard_input(
            name=name,
            command='\027'
        )
        sleep(1)

        if platform == 'darwin':
            interfaces = []

            for line in CommandProcess(
                    arguments=['networksetup', '-listallhardwareports']
            ).get_standard_output().splitlines():
                elements = line.split(':')

                if 'Device' == elements[0]:
                    interfaces += [elements[1].strip()]

            if len(interfaces) == 0:
                raise Exception('Could not determine network interface.')

            address = CommandProcess(
                arguments=['ipconfig', 'getifaddr', interfaces[0]]
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
                raise Exception('Could not determine network interface.')

            address = CommandProcess(
                arguments=['ifdata', '-pa', interfaces[0]]
            ).get_standard_output()
        elif platform == 'windows':
            raise Exception('Not implemented yet')
        else:
            raise Exception('Unexpected platform: ' + platform)

        chdir(web_directory)
        server = ThreadedTCPServer(
            (address, 8000),
            http.server.SimpleHTTPRequestHandler
        )
        server_thread = threading.Thread(target=server.serve_forever)
        server_thread.daemon = True
        server_thread.start()
        locator = 'http://' + address + ':8000'
        self.keyboard_input(
            name=name,
            command='auto url=' + locator + '/' + name + '.cfg\n'
        )
        self.wait_until_host_stops(name)

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

        if additions:
            self.start_host(name)
            sleep(60)
            self.attach_disc(
                name=name,
                controller_name=controller_name,
                medium='additions'
            )
            script = 'install-additions.sh'
            shutil.copyfile(
                src=join(
                    dirname(
                        abspath(virtual_box_tools.__file__)
                    ),
                    'script',
                    script
                ),
                dst=join(web_directory, script)
            )
            self.keyboard_input(
                name=name,
                command='root\n' + root_password + '\n'
                        + 'wget --output-document - ' + locator
                        + '/' + script + ' | sh -e\n'
            )
            sleep(120)
            self.attach_disc(
                name=name,
                controller_name=controller_name,
                medium='emptydrive'
            )
            self.stop_host(name)
            self.wait_until_host_stops(name)

        server.shutdown()
        server.server_close()

    def keyboard_input(self, name: str, command: str):
        for line in ScanCode.scan(command).splitlines():
            CommandProcess(
                arguments=[
                              'vboxmanage', 'controlvm', name,
                              'keyboardputscancode',
                          ] + line.split(' '),
                sudo_user=self.sudo_user
            )

    def attach_disc(
            self,
            name: str,
            controller_name: str,
            medium: str = 'emptydrive'
    ) -> None:
        CommandProcess(
            arguments=[
                'vboxmanage', 'storageattach', name,
                '--storagectl', controller_name,
                '--port', '1',
                '--device', '0',
                '--type', 'dvddrive',
                '--medium', medium
            ],
            sudo_user=self.sudo_user
        )

    def start_host(
            self, name: str,
            graphical: bool = False,
            wait: bool = False
    ) -> None:
        arguments = ['vboxmanage', 'startvm', name]

        if not graphical:
            arguments += ['--type', 'headless']

        CommandProcess(
            arguments=arguments,
            sudo_user=self.sudo_user
        )

        if wait:
            while True:
                sleep(60)
                address = self.get_virtual_host_address(name)

                if '' == address:
                    # Flush because the dots would not show up in some cases.
                    print('.', end='', flush=True)
                else:
                    print('')

                    break

    def stop_host(
            self,
            name: str,
            force: bool = False,
            wait: bool = False
    ) -> None:
        if force:
            arguments = ['poweroff']
        else:
            arguments = ['acpipowerbutton']

        CommandProcess(
            arguments=['vboxmanage', 'controlvm', name] + arguments,
            sudo_user=self.sudo_user
        )

        if wait and not force:
            self.wait_until_host_stops(name)

    def destroy_host(self, name: str) -> None:
        state = self.get_host_state(name)

        if state != 'poweroff':
            self.stop_host(name=name, force=True)

        CommandProcess(
            arguments=['vboxmanage', 'unregistervm', name, '--delete'],
            sudo_user=self.sudo_user
        )

    def get_host_state(self, name: str) -> str:
        output = CommandProcess(
            arguments=['vboxmanage', 'showvminfo', '--machinereadable', name],
            sudo_user=self.sudo_user
        ).get_standard_output()

        for line in output.splitlines():
            elements = line.split('=')

            if 'VMState' == elements[0]:
                return elements[1].replace('"', '')

        return 'unknown'

    def enumerate(self, name: str) -> str:
        return CommandProcess(
            arguments=['vboxmanage', 'guestproperty', 'enumerate', name],
            sudo_user=self.sudo_user
        ).get_standard_output()

    def get_virtual_host_address(self, name: str) -> str:
        output = self.enumerate(name)

        for line in output.splitlines():
            elements = line.split('=')

            if 'IP' == elements[0]:
                return elements[1].replace('"', '')

        return ''

    def get_physical_host_address(self, name: str) -> str:
        output = self.enumerate(name)

        for line in output.splitlines():
            elements = line.split('=')

            if 'MAC' == elements[0]:
                return elements[1].replace('"', '')

        return ''
