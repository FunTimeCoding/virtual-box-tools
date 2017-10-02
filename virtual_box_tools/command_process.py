from subprocess import Popen, PIPE


class CommandProcess:
    def __init__(self, arguments: list, sudo_user: str = '') -> None:
        if sudo_user != '':
            arguments = ['sudo', '-u', sudo_user] + arguments

        self.process = Popen(args=arguments, stdout=PIPE, stderr=PIPE)
        output, error = self.process.communicate()
        self.standard_output = output.decode().strip()
        self.standard_error = error.decode().strip()

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
