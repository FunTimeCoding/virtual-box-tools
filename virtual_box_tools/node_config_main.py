import argparse
from collections import OrderedDict
from os.path import expanduser, isfile
import sys

from python_utility.yaml_config import YamlConfig
import yaml

from virtual_box_tools.custom_argument_parser import CustomArgumentParser


class NodeConfigMain:
    def __init__(self, arguments: list):
        self.parser = self.get_parser()
        self.arguments = self.parser.parse_args(arguments)
        print(self.arguments)
        config = YamlConfig('~/.virtual-box-tools.yml')
        config_file_path = config.get('node_file')

        if config_file_path != '':
            config_file_path = expanduser(config_file_path)
            self.node_file_path = config_file_path
        else:
            self.node_file_path = expanduser(self.arguments.node_file)

        if isfile(self.node_file_path):
            self.yaml_tree = self.load_config_file()
        else:
            print('Node file not found: ' + self.node_file_path)
            sys.exit(1)

    def run(self):
        if 'add' in self.arguments:
            self.add(self.arguments.name)
        elif 'delete' in self.arguments:
            self.delete(self.arguments.name)
        elif 'list' in self.arguments:
            self.list_nodes()
        elif 'sort' in self.arguments:
            self.sort()
        else:
            self.parser.print_help()

    def sort(self):
        self.save_config_file()

    def add(self, node_name: str):
        entry = {
            'ip': self.arguments.ip,
            'mac': self.arguments.mac,
        }

        if self.arguments.aliases is not None:
            entry['canonical_names'] = self.arguments.aliases

        self.yaml_tree['node'][node_name] = entry
        self.save_config_file()

    def delete(self, node_name: str):
        if node_name in self.yaml_tree['node'].keys():
            self.yaml_tree['node'].pop(node_name, None)

        self.save_config_file()

    def list_nodes(self):
        print('Nodes:')

        for name, attributes in self.yaml_tree['node'].items():
            print('\nName: ' + name)
            print('IP: ' + attributes['ip'])
            print('MAC: ' + attributes['mac'])
            key = 'canonical_names'

            if key in attributes:
                print('Aliases: ' + str(attributes[key]))

    def load_config_file(self) -> dict:
        input_file = open(self.node_file_path, 'r')
        content = input_file.read()
        input_file.close()

        return yaml.load(content)

    def save_config_file(self):
        ordered_nodes = OrderedDict(sorted(self.yaml_tree['node'].items()))
        self.yaml_tree.pop('node', None)
        self.yaml_tree['node'] = {}

        for k, v in ordered_nodes.items():
            self.yaml_tree['node'][k] = v

        yaml_config = yaml.dump(self.yaml_tree, default_flow_style=False)

        if self.arguments.dry_run:
            print(yaml_config)
        else:
            output_file = open(self.node_file_path, 'w')
            output_file.write(yaml_config)
            output_file.close()

    @staticmethod
    def get_parser() -> CustomArgumentParser:
        parser = CustomArgumentParser(
            description='node configuration tool',
            formatter_class=argparse.ArgumentDefaultsHelpFormatter
        )
        subparsers = parser.add_subparsers()

        add_parent = CustomArgumentParser(add_help=False)
        add_parent.add_argument('--name', required=True)
        add_parent.add_argument('--ip', required=True)
        add_parent.add_argument('--mac', required=True)
        add_parent.add_argument('--aliases', nargs='+', metavar='ALIAS')

        add_parser = subparsers.add_parser(
            'add',
            parents=[add_parent],
            help='add or update a node'
        )
        add_parser.add_argument('add', action='store_true')

        delete_parent = CustomArgumentParser(add_help=False)
        delete_parent.add_argument('--name', required=True)

        delete_parser = subparsers.add_parser(
            'delete',
            parents=[delete_parent],
            help='delete a node'
        )
        delete_parser.add_argument('delete', action='store_true')

        sort_parser = subparsers.add_parser('sort', help='sort the node file')
        sort_parser.add_argument('sort', action='store_true')

        list_parser = subparsers.add_parser('list', help='list all nodes')
        list_parser.add_argument('list', action='store_true')

        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='do not write node file changes, only print them'
        )
        parser.add_argument(
            '--node-file',
            help='path to node file',
            default='/srv/salt/pillar/node.sls'
        )

        return parser