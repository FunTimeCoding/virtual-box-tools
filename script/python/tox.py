#!/usr/bin/env python3

from python_utility.command_process import CommandProcess


def main():
    process = CommandProcess(arguments=['tox'])
    process.print_output()


if __name__ == '__main__':
    main()
