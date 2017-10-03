from argparse import ArgumentDefaultsHelpFormatter
from collections import OrderedDict
from os.path import expanduser, isfile
from sys import exit as system_exit, argv

from virtual_box_tools.custom_argument_parser import CustomArgumentParser
from virtual_box_tools.yaml_config import YamlConfig
from yaml import load, dump


class HostConfiguration:
    def __init__(self, arguments: list):
        self.parser = self.create_parser()
        self.parsed_arguments = self.parser.parse_args(arguments)
        print(self.parsed_arguments)

        config = YamlConfig('~/.virtual-box-tools.yaml')
        config_file_path = config.get('host_file')
        self.CANONICAL_NAMES_KEY = 'canonical_name'
        self.CATCH_ALL_DOMAIN_KEY = 'catch_all_domain'

        if config_file_path != '':
            config_file_path = expanduser(config_file_path)
            self.host_file_path = config_file_path
        else:
            self.host_file_path = expanduser(self.parsed_arguments.host_file)

        if isfile(self.host_file_path):
            self.yaml_tree = self.load_config_file()
        else:
            print('File not found: ' + self.host_file_path)
            system_exit(1)

    @staticmethod
    def main() -> int:
        return HostConfiguration(argv[1:]).run()

    def run(self) -> int:
        result = 0

        if 'host' in self.parsed_arguments:
            if 'add' in self.parsed_arguments:
                self.add(self.parsed_arguments.name)
            elif 'delete' in self.parsed_arguments:
                result = self.delete(self.parsed_arguments.name)
            elif 'list' in self.parsed_arguments:
                self.list_hosts()
            elif 'sort' in self.parsed_arguments:
                self.sort()
            else:
                self.parser.print_help()
        elif 'service' in self.parsed_arguments:
            # TODO: Add commands add/list/delete
            self.parser.print_help()
        else:
            self.parser.print_help()

        return result

    @staticmethod
    def create_parser() -> CustomArgumentParser:
        parser = CustomArgumentParser(
            description='host configuration tool',
            formatter_class=ArgumentDefaultsHelpFormatter
        )
        subparsers = parser.add_subparsers()
        HostConfiguration.add_host_parser(subparsers)
        HostConfiguration.add_service_parser(subparsers)

        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='do not save changes'
        )
        parser.add_argument(
            '--host-file',
            help='path to host file',
            default='/srv/salt/pillar/host.sls'
        )

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

        add_parent = CustomArgumentParser(add_help=False)
        add_parent.add_argument('--name', required=True)
        add_parent.add_argument('--logical-address', required=True)
        add_parent.add_argument('--physical-address', required=True)
        add_parent.add_argument(
            '--canonical-names',
            nargs='+',
            metavar='CANONICAL_NAME',
        )
        add_parent.add_argument(
            '--catch-all-domains',
            nargs='+',
            metavar='CATCH_ALL_DOMAIN'
        )
        add_parser = host_subparsers.add_parser(
            'add',
            parents=[add_parent],
            help='add or update a host'
        )
        add_parser.add_argument('add', action='store_true')

        delete_parent = CustomArgumentParser(add_help=False)
        delete_parent.add_argument('--name', required=True)
        delete_parser = host_subparsers.add_parser(
            'delete',
            parents=[delete_parent],
            help='delete a host'
        )
        delete_parser.add_argument('delete', action='store_true')

        sort_parser = host_subparsers.add_parser(
            'sort',
            help='sort the host file'
        )
        sort_parser.add_argument('sort', action='store_true')

        list_parser = host_subparsers.add_parser('list', help='list all hosts')
        list_parser.add_argument('list', action='store_true')

    @staticmethod
    def add_service_parser(subparsers) -> None:
        service_parent = CustomArgumentParser(add_help=False)
        service_parser = subparsers.add_parser(
            'service',
            parents=[service_parent],
            help='manage services'
        )
        service_parser.add_argument('service', action='store_true')
        # service_subparsers = service_parser.add_subparsers()
        # TODO: This is where the service sub commands go.

    def sort(self) -> None:
        self.save_config_file()

    def add(self, host_name: str) -> None:
        entry = {
            'logical_address': self.parsed_arguments.logical_address,
            'physical_address': self.parsed_arguments.physical_address,
        }

        if self.CANONICAL_NAMES_KEY in self.parsed_arguments:
            entry[
                self.CANONICAL_NAMES_KEY
            ] = self.parsed_arguments.canonical_name

        if self.CATCH_ALL_DOMAIN_KEY in self.parsed_arguments:
            entry[
                self.CATCH_ALL_DOMAIN_KEY
            ] = self.parsed_arguments.catch_all_domain

        self.yaml_tree['host'][host_name] = entry
        self.save_config_file()

    def delete(self, host_name: str) -> int:
        if host_name in self.yaml_tree['host'].keys():
            self.yaml_tree['host'].pop(host_name, None)
            self.save_config_file()
            result = 0
        else:
            print('host not found: ' + host_name)
            result = 1

        return result

    def list_hosts(self) -> None:
        print('hosts:')

        for name, attributes in self.yaml_tree['host'].items():
            print('\nName: ' + name)
            print('Logical address: ' + attributes['logical_address'])
            print('Physical address: ' + attributes['physical_address'])

            if self.CANONICAL_NAMES_KEY in attributes:
                print(
                    'Canonical names: '
                    + str(attributes[self.CANONICAL_NAMES_KEY])
                )

            if self.CATCH_ALL_DOMAIN_KEY in attributes:
                print(
                    'Catch all domains: '
                    + str(attributes[self.CATCH_ALL_DOMAIN_KEY])
                )

    def load_config_file(self) -> dict:
        input_file = open(self.host_file_path, 'r')
        content = input_file.read()
        input_file.close()

        return load(content)

    def save_config_file(self) -> None:
        ordered_hosts = OrderedDict(sorted(self.yaml_tree['host'].items()))
        self.yaml_tree.pop('host', None)
        self.yaml_tree['host'] = {}

        for k, v in ordered_hosts.items():
            self.yaml_tree['host'][k] = v

        yaml_config = dump(self.yaml_tree, default_flow_style=False)

        if self.parsed_arguments.dry_run:
            print(yaml_config)
        else:
            output_file = open(self.host_file_path, 'w')
            output_file.write(yaml_config)
            output_file.close()
