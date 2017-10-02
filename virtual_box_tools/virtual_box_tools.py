from sys import argv


class VirtualBoxTools:
    def __init__(self, arguments: list):
        pass

    @staticmethod
    def main() -> int:
        return VirtualBoxTools(argv[1:]).run()

    def run(self) -> int:
        print('Hello friend.')

        return 0
