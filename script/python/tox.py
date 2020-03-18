#!/usr/bin/env python3

from python_skeleton.command_process import CommandProcess


def main():
    process = CommandProcess(['tox'])
    process.print_output()


if __name__ == '__main__':
    main()
