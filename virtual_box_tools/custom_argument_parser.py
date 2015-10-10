from argparse import ArgumentParser
import sys


class CustomArgumentParser(ArgumentParser):
    def error(self, message):
        sys.stderr.write('Error: %s\n' % message)

        sys.exit(1)
