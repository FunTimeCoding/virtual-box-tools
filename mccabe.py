#!/usr/bin/env python3

from python_utility.command_process import CommandProcess


def main():
    process = CommandProcess([
        'flake8',
        '--exclude', '.venv,.git,.idea,.tox',
        '--verbose',
        '--max-complexity', '5'
    ])
    process.print_output()


if __name__ == '__main__':
    main()
