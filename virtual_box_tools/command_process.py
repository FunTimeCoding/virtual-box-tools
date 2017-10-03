from subprocess import Popen, PIPE


class CommandFailed(BaseException):
    def __init__(
            self,
            return_code: int,
            standard_output: str,
            standard_error: str
    ):
        self.return_code = return_code
        self.standard_output = standard_output
        self.standard_error = standard_error
        self.message = 'Return code: ' + str(self.return_code) \
                       + '\nStandard output: ' + self.standard_output \
                       + '\nStandard error: ' + self.standard_error

    def get_standard_output(self):
        return self.standard_output

    def get_standard_error(self):
        return self.standard_error

    def get_return_code(self):
        return self.return_code


class CommandProcess:
    def __init__(self, arguments: list, sudo_user: str = '') -> None:
        if sudo_user != '':
            arguments = ['sudo', '-u', sudo_user] + arguments

        self.process = Popen(args=arguments, stdout=PIPE, stderr=PIPE)
        output, error = self.process.communicate()
        self.standard_output = output.decode().strip()
        self.standard_error = error.decode().strip()

        if self.process.returncode != 0:
            raise CommandFailed(
                standard_output=self.get_standard_output(),
                standard_error=self.get_standard_error(),
                return_code=self.process.returncode
            )

    def print_output(self) -> None:
        if self.standard_error != '':
            print(self.get_standard_error())

        if self.standard_output != '':
            print(self.get_standard_output())

    def get_standard_output(self):
        return self.standard_output

    def get_standard_error(self):
        return self.standard_error

    def get_return_code(self):
        return self.process.returncode
