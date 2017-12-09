from subprocess import Popen, PIPE
from os import name as os_name, environ


class CommandFailed(BaseException):
    def __init__(
            self,
            command: list,
            return_code: int,
            standard_output: str,
            standard_error: str
    ):
        self.command = command
        self.return_code = return_code
        self.standard_output = standard_output
        self.standard_error = standard_error
        self.message = 'CommandFailed: ' + ' '.join(command) \
                       + '\nReturn code: ' + str(self.return_code) \
                       + '\nPath: ' + environ['PATH']

        if self.standard_output != '':
            self.message += '\nStandard output: \n' + self.standard_output

        if self.standard_error != '':
            self.message += '\nStandard error: \n' + self.standard_error

    def get_command(self) -> str:
        return ' '.join(self.command)

    def get_standard_output(self) -> str:
        return self.standard_output

    def get_standard_error(self) -> str:
        return self.standard_error

    def get_return_code(self) -> int:
        return self.return_code

    def __str__(self) -> str:
        return self.message


class CommandProcess:
    def __init__(self, arguments: list, sudo_user: str = '') -> None:
        if sudo_user != '':
            arguments = ['sudo', '-u', sudo_user] + arguments

        # shell=True is required for Windows to find executables in PATH
        if 'nt' == os_name:
            shell = True
        else:
            shell = False

        try:
            self.process = Popen(
                args=arguments,
                stdout=PIPE,
                stderr=PIPE,
                shell=shell
            )
        except FileNotFoundError as exception:
            raise CommandFailed(
                command=arguments,
                standard_output='File not found: ' + arguments[0],
                standard_error=exception.strerror,
                return_code=-1
            )

        output, error = self.process.communicate()
        self.standard_output = output.decode().strip()
        self.standard_error = error.decode().strip()

        if self.process.returncode != 0:
            raise CommandFailed(
                command=arguments,
                standard_output=self.get_standard_output(),
                standard_error=self.get_standard_error(),
                return_code=self.process.returncode
            )

    def print_output(self) -> None:
        if self.standard_error != '':
            print(self.get_standard_error())

        if self.standard_output != '':
            print(self.get_standard_output())

    def get_standard_output(self) -> str:
        return self.standard_output

    def get_standard_error(self) -> str:
        return self.standard_error

    def get_return_code(self) -> int:
        return self.process.returncode
