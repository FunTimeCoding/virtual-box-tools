from getpass import getuser
from socket import getfqdn
from argparse import ArgumentDefaultsHelpFormatter
from os import name as operating_system_name, umask, makedirs, chdir
from os.path import expanduser, exists, join, abspath, dirname
from sys import exit as system_exit, argv, platform
from time import sleep
from http.server import SimpleHTTPRequestHandler
from socketserver import ThreadingMixIn, TCPServer
from shutil import copyfile, copyfileobj, rmtree, which
from threading import Thread
from urllib.request import urlopen
from tarfile import open as open_tar_file
from sqlite3 import connect as sequel_lite_connect
from string import ascii_uppercase, ascii_lowercase, digits
from random import choice

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


class ThreadedTCPServer(ThreadingMixIn, TCPServer):
    logging = False


class CustomLoggingHandler(SimpleHTTPRequestHandler):
    def log_message(self, log_format, *args):
        if self.server.logging:
            SimpleHTTPRequestHandler.log_message(
                self, log_format,
                *args
            )


class VirtualBoxTools:
    DEFAULT_CORES = 1
    DEFAULT_MEMORY = 4096
    DEFAULT_DISK_SIZE = 64
    HOST_COMMAND = 'host'
    START_COMMAND = 'start'
    STOP_COMMAND = 'stop'
    SHOW_COMMAND = 'show'
    CREATE_COMMAND = 'create'
    LIST_COMMAND = 'list'
    POWER_OFF_STATE = 'poweroff'

    def __init__(self, arguments: list):
        self.parser = self.create_parser()
        self.parsed_arguments = self.parser.parse_args(arguments)
        config = YamlConfig('~/.virtual-box-tools.yaml')
        self.sudo_user = config.get('sudo_user')

    @staticmethod
    def main() -> int:
        return VirtualBoxTools(argv[1:]).run()

    def run(self) -> int:
        if self.HOST_COMMAND in self.parsed_arguments:
            commands = Commands(self.sudo_user)

            if self.LIST_COMMAND in self.parsed_arguments:
                print(commands.list_hosts())
            elif self.CREATE_COMMAND in self.parsed_arguments:
                try:
                    commands.create_host(
                        name=self.parsed_arguments.name,
                        cores=self.parsed_arguments.cores,
                        memory=self.parsed_arguments.memory,
                        disk_size=self.parsed_arguments.disk_size,
                        bridge_interface=self.parsed_arguments.bridge_interface,
                        skip_preseed=self.parsed_arguments.skip_preseed,
                        graphical=self.parsed_arguments.graphical,
                        no_additions=self.parsed_arguments.no_additions
                    )
                except CommandFailed as exception:
                    print(exception)
            elif 'destroy' in self.parsed_arguments:
                try:
                    commands.destroy_host(name=self.parsed_arguments.name)
                except CommandFailed as exception:
                    print(exception)
            elif self.START_COMMAND in self.parsed_arguments:
                try:
                    commands.start_host(
                        name=self.parsed_arguments.name,
                        graphical=self.parsed_arguments.graphical,
                        wait=self.parsed_arguments.wait
                    )
                except CommandFailed as exception:
                    print(exception)
            elif self.STOP_COMMAND in self.parsed_arguments:
                try:
                    commands.stop_host(
                        name=self.parsed_arguments.name,
                        force=self.parsed_arguments.force,
                        wait=self.parsed_arguments.wait
                    )
                except CommandFailed as exception:
                    print(exception)
            elif self.SHOW_COMMAND in self.parsed_arguments:
                try:
                    print(
                        commands.show_host(
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

    def create_parser(self) -> CustomArgumentParser:
        parser = CustomArgumentParser(
            description='Wrapper for VirtualBox to simplify operations',
            formatter_class=ArgumentDefaultsHelpFormatter
        )
        subparsers = parser.add_subparsers()
        self.add_host_parser(subparsers)

        return parser

    def add_host_parser(self, subparsers) -> None:
        host_parent = CustomArgumentParser(add_help=False)
        host_parser = subparsers.add_parser(
            self.HOST_COMMAND,
            parents=[host_parent],
            help='manage hosts'
        )
        host_parser.add_argument(self.HOST_COMMAND, action='store_true')
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
        create_parent.add_argument('--no-additions', action='store_true')
        create_parent.add_argument('--bridge-interface', default='')
        create_parser = host_subparsers.add_parser(
            self.CREATE_COMMAND,
            parents=[create_parent],
            help='create a host'
        )
        create_parser.add_argument(self.CREATE_COMMAND, action='store_true')

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
            self.SHOW_COMMAND,
            parents=[show_parent],
            help='show a host'
        )
        show_parser.add_argument(self.SHOW_COMMAND, action='store_true')

        start_parent = CustomArgumentParser(add_help=False)
        start_parent.add_argument('--name', required=True)
        start_parent.add_argument('--graphical', action='store_true')
        start_parent.add_argument('--wait', action='store_true')
        start_parser = host_subparsers.add_parser(
            self.START_COMMAND,
            parents=[start_parent],
            help='start a host'
        )
        start_parser.add_argument(self.START_COMMAND, action='store_true')

        stop_parent = CustomArgumentParser(add_help=False)
        stop_parent.add_argument('--name', required=True)
        stop_parent.add_argument('--force', action='store_true')
        stop_parent.add_argument('--wait', action='store_true')
        stop_parser = host_subparsers.add_parser(
            self.STOP_COMMAND,
            parents=[stop_parent],
            help='stop a host'
        )
        stop_parser.add_argument(self.STOP_COMMAND, action='store_true')

        list_parser = host_subparsers.add_parser(
            self.LIST_COMMAND,
            help='list hosts'
        )
        list_parser.add_argument(self.LIST_COMMAND, action='store_true')


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

    def show_host(self, name: str) -> []:
        virtual_address = self.get_virtual_host_address(name)
        physical_address = self.get_physical_host_address(name)
        result = 'state: ' + self.get_host_state(name)

        if virtual_address != '':
            result += '\nvirtual address: ' + virtual_address

        if physical_address != '':
            result += '\nphysical address: ' + physical_address

        return result

    @staticmethod
    def generate_password() -> str:
        chars = ascii_uppercase + ascii_lowercase + digits

        return ''.join(choice(chars) for _ in range(14))

    def get_password_sqlite(self, user: str, name: str, domain: str) -> str:
        tools_directory = expanduser('~/.virtual-box-tools')
        if not exists(tools_directory):
            makedirs(tools_directory)

        # Make file permissions 600.
        old_mask = umask(0o077)
        connection = sequel_lite_connect(join(tools_directory, 'user.sqlite'))
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

    def wait_for_host_to_stop(self, name: str) -> None:
        while True:
            sleep(10)

            if 'running' != self.get_host_state(name):
                break

    def create_host(
            self, name: str,
            cores: int = VirtualBoxTools.DEFAULT_CORES,
            memory: int = VirtualBoxTools.DEFAULT_MEMORY,
            disk_size: int = VirtualBoxTools.DEFAULT_DISK_SIZE,
            bridge_interface: str = '',
            skip_preseed: bool = False,
            graphical: bool = False,
            no_additions: bool = False
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
            with urlopen(
                    'http://ftp.debian.org/debian/dists/stretch/main'
                    '/installer-amd64/current/images/netboot/netboot.tar.gz'
            ) as response, open(archive, 'wb') as out_file:
                copyfileobj(response, out_file)

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
                rmtree(trivial_directory)
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
            open_archive = open_tar_file(archive, 'r:gz')
            open_archive.extractall(trivial_directory)
        else:
            extract_path = which('vbt-extract')
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
        # Send escape key to open installer command input.
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
        server = ThreadedTCPServer((address, 8000), CustomLoggingHandler)
        server_thread = Thread(target=server.serve_forever)
        server_thread.daemon = True
        server_thread.start()
        locator = 'http://' + address + ':8000'
        self.keyboard_input(
            name=name,
            command='auto url=' + locator + '/' + name + '.cfg\n'
        )
        self.wait_for_host_to_stop(name)

        CommandProcess(
            arguments=[
                'vboxmanage', 'modifyvm', name,
                '--boot1', 'disk',
            ],
            sudo_user=self.sudo_user
        )

        if not no_additions:
            self.start_host(name)
            sleep(60)
            self.attach_disc(
                name=name,
                controller_name=controller_name,
                medium='additions'
            )
            script = 'install-additions.sh'
            copyfile(
                src=join(
                    dirname(abspath(virtual_box_tools.__file__)),
                    'script',
                    script
                ),
                dst=join(web_directory, script)
            )
            self.keyboard_input(name=name, command='root\n')
            sleep(5)
            self.keyboard_input(
                name=name,
                command=root_password + '\n'
            )
            sleep(5)
            self.keyboard_input(
                name=name,
                command='wget --output-document - ' + locator
                        + '/' + script + ' | sh -e\n'
            )
            sleep(120)
            self.stop_host(name)
            self.wait_for_host_to_stop(name)
            self.attach_disc(
                name=name,
                controller_name=controller_name,
                medium='emptydrive'
            )

        server.shutdown()
        server.server_close()

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
                sleep(10)

                if '' != self.get_virtual_host_address(name):
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
            self.wait_for_host_to_stop(name)

    def destroy_host(self, name: str) -> None:
        state = self.get_host_state(name)

        if state != VirtualBoxTools.POWER_OFF_STATE:
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

    def get_guest_property(self, name: str, key: str) -> str:
        return CommandProcess(
            arguments=['vboxmanage', 'guestproperty', 'get', name, key],
            sudo_user=self.sudo_user
        ).get_standard_output()

    def get_virtual_host_address(self, name: str) -> str:
        guest_property = self.get_guest_property(
            name=name, key='/VirtualBox/GuestInfo/Net/0/V4/IP'
        )

        # It returns this address when the virtual machine is off.
        if guest_property == 'No value set!' or guest_property == '10.0.2.15':
            result = ''
        else:
            result = guest_property.split(' ')[1]

        return result

    def get_physical_host_address(self, name: str) -> str:
        guest_property = self.get_guest_property(
            name=name, key='/VirtualBox/GuestInfo/Net/0/MAC'
        )

        if guest_property == 'No value set!':
            result = ''
        else:
            temporary = iter(guest_property.split(' ')[1])

            result = ':'.join(
                a + b for a, b in zip(temporary, temporary)
            )

        return result
