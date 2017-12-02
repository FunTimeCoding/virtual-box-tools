from argparse import ArgumentDefaultsHelpFormatter
from sys import argv
import tarfile

from virtual_box_tools.custom_argument_parser import CustomArgumentParser


class Extract:
    def __init__(self, arguments: list):
        self.parser = self.create_parser()
        self.parsed_arguments = self.parser.parse_args(arguments)

    @staticmethod
    def main() -> int:
        return Extract(argv[1:]).run()

    def run(self) -> int:
        open_archive = tarfile.open(self.parsed_arguments.archive, 'r:gz')
        open_archive.extractall(self.parsed_arguments.output_directory)

        return 0

    @staticmethod
    def create_parser() -> CustomArgumentParser:
        parser = CustomArgumentParser(
            description='Wrapper around VirtualBox to simplify operations',
            formatter_class=ArgumentDefaultsHelpFormatter
        )
        parser.add_argument('archive')
        parser.add_argument('output_directory')

        return parser
