from argparse import ArgumentDefaultsHelpFormatter
from sys import argv

from virtual_box_tools.command_process import CommandProcess, \
    CommandFailed
from virtual_box_tools.custom_argument_parser import CustomArgumentParser
from virtual_box_tools.yaml_config import YamlConfig


class Commands:
    def __init__(self, sudo_user: str):
        self.sudo_user = sudo_user

    def list_virtual_machines(self) -> []:
        hosts = []

        for line in CommandProcess(
                arguments=['vboxmanage', 'list', 'vms'],
                sudo_user=self.sudo_user
        ).get_standard_output().splitlines():
            hosts += [{'name': line.split(' ')[0][1:-1]}]

        return hosts

    def get_virtual_machine_information(self, name: str) -> []:
        return CommandProcess(
                arguments=['vboxmanage', 'guestproperty', 'enumerate', name],
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
        print(Commands(self.sudo_user).list_virtual_machines())

        return 0

    @staticmethod
    def create_parser() -> CustomArgumentParser:
        parser = CustomArgumentParser(
            description='host configuration tool',
            formatter_class=ArgumentDefaultsHelpFormatter
        )
        parser.add_argument(
            '--canonical-names',
            nargs='+',
            metavar='CANONICAL_NAME',
        )
        subparsers = parser.add_subparsers()
        # VirtualBoxTools.add_host_parser(subparsers)
        # VirtualBoxTools.add_service_parser(subparsers)
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
