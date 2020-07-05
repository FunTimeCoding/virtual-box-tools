#!/usr/bin/env python3

from python_utility.command_process import CommandProcess


def main():
    process = CommandProcess(
        arguments=[
            'flake8',
            '--exclude', '.git,.idea,.tox',
            '--verbose',
            '--max-complexity', '5'
        ],
    )
    process.print_output()


if __name__ == '__main__':
    main()
