from argparse import ArgumentParser
from sys import exit, stderr


class CustomArgumentParser(ArgumentParser):
    def error(self, message) -> None:
        stderr.write('Error: %s\n' % message)

        exit(1)
