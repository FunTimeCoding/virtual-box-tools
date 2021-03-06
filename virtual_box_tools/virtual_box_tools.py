from getpass import getuser
from json import dumps
from socket import getfqdn, socket, AF_INET, SOCK_STREAM
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
from virtual_box_tools.command_process import CommandProcess, CommandFailed
from virtual_box_tools.custom_argument_parser import CustomArgumentParser
from virtual_box_tools.yaml_config import YamlConfig

if 'nt' == operating_system_name:
    import virtual_box_tools.windows_password_database as pwd
else:
    import pwd


class ThreadedTCPServer(ThreadingMixIn, TCPServer):
    logging = False


class CustomLoggingHandler(SimpleHTTPRequestHandler):
    def log_message(self, log_format, *args) -> None:
        if self.server.logging:
            SimpleHTTPRequestHandler.log_message(
                self, log_format,
                *args
            )


class VirtualBoxTools:
    DEFAULT_CORES = 1
    DEFAULT_MEMORY = 2048
    DEFAULT_DISK_SIZE = 16
    STRETCH_RELEASE = 'stretch'
    BUSTER_RELEASE = 'buster'
    HOST_COMMAND = 'host'
    START_COMMAND = 'start'
    STOP_COMMAND = 'stop'
    SHOW_COMMAND = 'show'
    CREATE_COMMAND = 'create'
    LIST_COMMAND = 'list'
    POWER_OFF_STATE = 'poweroff'

    def __init__(self, arguments: list) -> None:
        config = YamlConfig('~/.virtual-box-tools.yaml')
        self.sudo_user = config.get('sudo_user')
        self.bridge_interface = config.get('bridge_interface')
        self.parser = self.create_parser()
        self.parsed_arguments = self.parser.parse_args(arguments)

    @staticmethod
    def main() -> int:
        return VirtualBoxTools(argv[1:]).run()

    def run(self) -> int:
        arguments = self.parsed_arguments

        if self.HOST_COMMAND in arguments:
            commands = Commands(self.sudo_user)

            if self.LIST_COMMAND in arguments:
                print(
                    dumps(
                        commands.list_hosts(list_all=arguments.all)
                    )
                )
            elif self.CREATE_COMMAND in arguments:
                try:
                    commands.create_host(
                        host_name=arguments.name,
                        cores=arguments.cores,
                        memory=arguments.memory,
                        disk_size=int(arguments.disk_size),
                        bridge_interface=arguments.bridge_interface,
                        graphical=arguments.graphical,
                        no_post_install=arguments.no_post_install,
                        proxy=arguments.proxy,
                        release=arguments.release,
                        user_name=arguments.user_name,
                        real_name=arguments.real_name,
                    )

                    if arguments.show_after_install:
                        commands.start_host(
                            name=arguments.name,
                            graphical=arguments.graphical,
                            wait=True,
                        )
                        print(commands.show_host(arguments.name))
                        commands.stop_host(
                            name=arguments.name,
                            force=False,
                            wait=True,
                        )
                except CommandFailed as exception:
                    print(exception)
            elif 'destroy' in arguments:
                try:
                    commands.destroy_host(name=arguments.name)
                except CommandFailed as exception:
                    print(exception)
            elif self.START_COMMAND in arguments:
                try:
                    commands.start_host(
                        name=arguments.name,
                        graphical=arguments.graphical,
                        wait=arguments.wait,
                    )
                except CommandFailed as exception:
                    print(exception)
            elif self.STOP_COMMAND in arguments:
                try:
                    commands.stop_host(
                        name=arguments.name,
                        force=arguments.force,
                        wait=arguments.wait,
                    )
                except CommandFailed as exception:
                    print(exception)
            elif self.SHOW_COMMAND in arguments:
                try:
                    print(commands.show_host(arguments.name))
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
            help='manage hosts',
        )
        host_parser.add_argument(self.HOST_COMMAND, action='store_true')
        host_subparsers = host_parser.add_subparsers()

        create_parent = CustomArgumentParser(add_help=False)
        create_parent.add_argument('--name', required=True)
        create_parent.add_argument(
            '--bridge-interface',
            default=self.bridge_interface,
        )
        create_parent.add_argument(
            '--cores',
            default=VirtualBoxTools.DEFAULT_CORES,
        )
        create_parent.add_argument(
            '--memory',
            default=VirtualBoxTools.DEFAULT_MEMORY,
        )
        create_parent.add_argument(
            '--disk-size',
            default=VirtualBoxTools.DEFAULT_DISK_SIZE,
        )
        create_parent.add_argument('--graphical', action='store_true')
        create_parent.add_argument('--no-post-install', action='store_true')
        create_parent.add_argument('--show-after-install', action='store_true')
        create_parent.add_argument('--proxy', default='')
        create_parent.add_argument(
            '--release',
            default=VirtualBoxTools.BUSTER_RELEASE,
            choices=[
                VirtualBoxTools.BUSTER_RELEASE,
                VirtualBoxTools.STRETCH_RELEASE,
            ],
        )
        create_parent.add_argument('--user-name', default='')
        create_parent.add_argument('--real-name', default='')
        create_parser = host_subparsers.add_parser(
            self.CREATE_COMMAND,
            parents=[create_parent],
            help='create a host',
        )
        create_parser.add_argument(self.CREATE_COMMAND, action='store_true')

        destroy_parent = CustomArgumentParser(add_help=False)
        destroy_parent.add_argument('--name', required=True)
        destroy_parser = host_subparsers.add_parser(
            'destroy',
            parents=[destroy_parent],
            help='destroy a host',
        )
        destroy_parser.add_argument('destroy', action='store_true')

        show_parent = CustomArgumentParser(add_help=False)
        show_parent.add_argument('--name', required=True)
        show_parser = host_subparsers.add_parser(
            self.SHOW_COMMAND,
            parents=[show_parent],
            help='show a host',
        )
        show_parser.add_argument(self.SHOW_COMMAND, action='store_true')

        start_parent = CustomArgumentParser(add_help=False)
        start_parent.add_argument('--name', required=True)
        start_parent.add_argument('--graphical', action='store_true')
        start_parent.add_argument('--wait', action='store_true')
        start_parser = host_subparsers.add_parser(
            self.START_COMMAND,
            parents=[start_parent],
            help='start a host',
        )
        start_parser.add_argument(self.START_COMMAND, action='store_true')

        stop_parent = CustomArgumentParser(add_help=False)
        stop_parent.add_argument('--name', required=True)
        stop_parent.add_argument('--force', action='store_true')
        stop_parent.add_argument('--wait', action='store_true')
        stop_parser = host_subparsers.add_parser(
            self.STOP_COMMAND,
            parents=[stop_parent],
            help='stop a host',
        )
        stop_parser.add_argument(self.STOP_COMMAND, action='store_true')

        list_parser = host_subparsers.add_parser(
            self.LIST_COMMAND,
            help='list hosts',
        )
        list_parser.add_argument('--all', action='store_true')
        list_parser.add_argument(self.LIST_COMMAND, action='store_true')


class Commands:
    def __init__(self, sudo_user: str) -> None:
        self.sudo_user = sudo_user

    def list_hosts(self, list_all: bool = False) -> []:
        hosts = []

        if list_all:
            group = 'vms'
        else:
            group = 'runningvms'

        for line in CommandProcess(
                arguments=['vboxmanage', 'list', group],
                sudo_user=self.sudo_user,
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

    def get_password_sqlite(
            self,
            user_name: str,
            host_name: str,
            domain_name: str
    ) -> str:
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
            [user_name, host_name, domain_name],
        )
        result = cursor.fetchone()

        if result is None:
            password = self.generate_password()
            cursor.execute(
                'INSERT INTO user VALUES (?, ?, ?, ?)',
                [user_name, host_name, domain_name, password],
            )
            connection.commit()
        else:
            password = result[0]

        cursor.close()

        return password

    def get_password_pass(
            self,
            user_name: str,
            host_name: str,
            domain_name: str
    ) -> str:
        password = ''

        try:
            get_password_process = CommandProcess(
                arguments=[
                    'pass',
                    'host/' + host_name + '.' + domain_name + '/' + user_name
                ],
                sudo_user=self.sudo_user,
            )
            password = get_password_process.get_standard_output()
        except CommandFailed as exception:
            if 'not in the password store.' in exception.get_standard_error():
                generate_password_process = CommandProcess(
                    arguments=[
                        'pass', 'generate',
                        'host/' + host_name + '.' + domain_name
                        + '/' + user_name,
                        '--no-symbols', '14'
                    ],
                    sudo_user=self.sudo_user,
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

    @staticmethod
    def get_domain() -> str:
        return '.'.join(getfqdn().split('.')[1:])

    # TODO: Create host first, then grab physical address to configure hostname
    # and domain name through DHCP. Not helpful in non-DHCP environments. It
    # would be more clean to configure the new host using DHCP provided
    # hostname and domain.
    def create_host(
            self,
            host_name: str,
            bridge_interface: str,
            cores: int = VirtualBoxTools.DEFAULT_CORES,
            memory: int = VirtualBoxTools.DEFAULT_MEMORY,
            disk_size: int = VirtualBoxTools.DEFAULT_DISK_SIZE,
            graphical: bool = False,
            no_post_install: bool = False,
            proxy: str = '',
            release: str = VirtualBoxTools.BUSTER_RELEASE,
            user_name: str = '',
            real_name: str = '',
    ) -> None:
        domain_name = self.get_domain()
        root_password = self.get_password_sqlite(
            user_name='root',
            host_name=host_name,
            domain_name=domain_name,
        )

        if user_name == '':
            user_name = getuser()

        if real_name == '':
            real_name = pwd.getpwnam(user_name)[4]

        user_password = self.get_password_sqlite(
            user_name=user_name,
            host_name=host_name,
            domain_name=domain_name,
        )
        user_home = expanduser('~')
        temporary_directory = join(user_home, 'tmp')
        web_directory = join(temporary_directory, 'web')

        if not exists(web_directory):
            makedirs(web_directory)

        debian_tools_arguments = [
            'dt',
            '--release', release,
            '--hostname', host_name,
            '--domain', domain_name,
            '--root-password', root_password,
            '--user-name', user_name,
            '--user-password', user_password,
            '--user-real-name', real_name,
            '--output-document', join(web_directory, host_name + '.cfg'),
        ]

        if proxy != '':
            debian_tools_arguments += ['--proxy', proxy]

        # Do not use sudo for dt, because it would not be available in PATH.
        CommandProcess(arguments=debian_tools_arguments)

        CommandProcess(
            arguments=[
                'vboxmanage', 'createvm',
                '--name', host_name,
                '--register',
                '--ostype', 'Debian_64',
            ],
            sudo_user=self.sudo_user,
        )
        controller_name = 'SATA'
        CommandProcess(
            arguments=[
                'vboxmanage', 'storagectl', host_name,
                '--name', controller_name,
                '--add', 'sata',
            ],
            sudo_user=self.sudo_user,
        )

        if self.sudo_user == '':
            home_directory = user_home
        else:
            home_directory = join('/home', self.sudo_user)

        disk_path = join(
            home_directory,
            'VirtualBox VMs',
            host_name,
            host_name + '.vdi',
        )
        CommandProcess(
            arguments=[
                'vboxmanage', 'createmedium', 'disk',
                '--filename', disk_path,
                '--size', str(disk_size * 1024),
            ],
            sudo_user=self.sudo_user
        )
        CommandProcess(
            arguments=[
                'vboxmanage', 'storageattach', host_name,
                '--storagectl',
                controller_name,
                '--port', '0',
                '--device', '0',
                '--type', 'hdd',
                '--medium', disk_path,
            ],
            sudo_user=self.sudo_user
        )
        self.attach_disc(
            name=host_name,
            controller_name=controller_name,
            medium='emptydrive',
        )
        CommandProcess(
            arguments=[
                'vboxmanage', 'modifyvm', host_name,
                '--acpi', 'on',
                '--cpus', str(cores),
                '--memory', str(memory),
                '--vram', '16',
            ],
            sudo_user=self.sudo_user
        )

        if not exists(temporary_directory):
            makedirs(temporary_directory)

        archive = join(temporary_directory, 'netboot-' + release + '.tar.gz')

        if not exists(archive):
            with urlopen(
                    'http://ftp.debian.org/debian/dists/' + release + '/main'
                                                                      '/installer-amd64/current/images/netboot/netboot.tar.gz'
            ) as response, open(archive, 'wb') as out_file:
                copyfileobj(response, out_file)

        if platform == 'darwin':
            configuration_directory = join(
                home_directory,
                'Library',
                'VirtualBox',
            )
        else:
            configuration_directory = join(
                home_directory,
                '.config',
                'VirtualBox',
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
                sudo_user=self.sudo_user,
            )
            CommandProcess(
                arguments=[
                    'chmod',
                    '755',
                    join(trivial_directory, 'debian-installer/amd64/pxelinux.0')
                ],
                sudo_user=self.sudo_user,
            )

        CommandProcess(
            arguments=[
                'vboxmanage', 'modifyvm', host_name,
                '--nic1', 'nat',
                '--boot1', 'net',
                '--nattftpfile1', 'pxelinux.0',
            ],
            sudo_user=self.sudo_user,
        )

        start_arguments = ['vboxmanage', 'startvm', host_name]

        if graphical is False:
            start_arguments += ['--type', 'headless']

        CommandProcess(
            arguments=start_arguments,
            sudo_user=self.sudo_user,
        )
        sleep(20)
        # Send escape key to open installer command input.
        self.keyboard_input(
            name=host_name,
            command='\027',
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
            address = CommandProcess(
                arguments=['ifdata', '-pa', bridge_interface]
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
            name=host_name,
            command='auto url=' + locator + '/' + host_name + '.cfg'
                    + ' netcfg/get_hostname=' + host_name
                    + ' netcfg/get_domain=' + domain_name + '\n',
        )
        self.wait_for_host_to_stop(host_name)

        CommandProcess(
            arguments=[
                'vboxmanage', 'modifyvm', host_name,
                '--boot1', 'disk',
            ],
            sudo_user=self.sudo_user
        )

        if not no_post_install:
            # Sleep to avoid VBOX_E_INVALID_OBJECT_STATE.
            sleep(5)
            self.start_host(name=host_name, graphical=graphical)
            sleep(60)
            self.attach_disc(
                name=host_name,
                controller_name=controller_name,
                medium='additions',
            )
            script = 'post-install.sh'
            copyfile(
                src=join(
                    dirname(abspath(virtual_box_tools.__file__)),
                    'script',
                    script,
                ),
                dst=join(web_directory, script)
            )
            self.keyboard_input(name=host_name, command='root\n')
            sleep(5)
            self.keyboard_input(
                name=host_name,
                command=root_password + '\n',
            )
            sleep(5)
            self.keyboard_input(
                name=host_name,
                command='wget --output-document - ' + locator
                        + '/' + script + ' | sh -ex\n',
            )
            self.wait_for_host_to_stop(host_name)
            self.attach_disc(
                name=host_name,
                controller_name=controller_name,
                medium='emptydrive',
            )

        server.shutdown()
        server.server_close()
        CommandProcess(
            arguments=[
                'vboxmanage', 'modifyvm', host_name,
                '--nic1', 'bridged',
                '--bridgeadapter1', bridge_interface,
            ],
            sudo_user=self.sudo_user,
        )

    def keyboard_input(self, name: str, command: str) -> None:
        for line in ScanCode.scan(command).splitlines():
            CommandProcess(
                arguments=[
                              'vboxmanage', 'controlvm', name,
                              'keyboardputscancode',
                          ] + line.split(' '),
                sudo_user=self.sudo_user,
            )

    def attach_disc(
            self,
            name: str,
            controller_name: str,
            medium: str = 'emptydrive',
    ) -> None:
        CommandProcess(
            arguments=[
                'vboxmanage', 'storageattach', name,
                '--storagectl', controller_name,
                '--port', '1',
                '--device', '0',
                '--type', 'dvddrive',
                '--medium', medium,
            ],
            sudo_user=self.sudo_user,
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
            sudo_user=self.sudo_user,
        )

        if wait:
            while True:
                sleep(2)
                check_socket = socket(AF_INET, SOCK_STREAM)
                check_socket.settimeout(1)

                if check_socket.connect_ex(
                        (name + '.' + Commands.get_domain(), 22)
                ) is 0:
                    break

    def stop_host(
            self,
            name: str,
            force: bool = False,
            wait: bool = False,
    ) -> None:
        if force:
            state = 'poweroff'
        else:
            state = 'acpipowerbutton'

        CommandProcess(
            arguments=['vboxmanage', 'controlvm', name, state],
            sudo_user=self.sudo_user
        )
        # Sleep to avoid VBOX_E_INVALID_OBJECT_STATE.
        sleep(5)

        if wait and not force:
            self.wait_for_host_to_stop(name)

    def destroy_host(self, name: str) -> None:
        state = self.get_host_state(name)

        if state != VirtualBoxTools.POWER_OFF_STATE:
            self.stop_host(name=name, force=True)

        CommandProcess(
            arguments=['vboxmanage', 'unregistervm', name, '--delete'],
            sudo_user=self.sudo_user,
        )

    def get_host_state(self, name: str) -> str:
        output = CommandProcess(
            arguments=['vboxmanage', 'showvminfo', '--machinereadable', name],
            sudo_user=self.sudo_user,
        ).get_standard_output()

        for line in output.splitlines():
            elements = line.split('=')

            if 'VMState' == elements[0]:
                return elements[1].replace('"', '')

        return 'unknown'

    def get_guest_property(self, name: str, key: str) -> str:
        return CommandProcess(
            arguments=['vboxmanage', 'guestproperty', 'get', name, key],
            sudo_user=self.sudo_user,
        ).get_standard_output()

    def get_virtual_host_address(self, name: str) -> str:
        guest_property = self.get_guest_property(
            name=name, key='/VirtualBox/GuestInfo/Net/0/V4/IP'
        )
        second_element = guest_property.split(' ')[1]

        # It returns this address when the virtual machine is off.
        if guest_property == 'No value set!' or second_element == '10.0.2.15':
            result = ''
        else:
            result = second_element

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
                keys + values for keys, values in zip(temporary, temporary)
            )

        return result
