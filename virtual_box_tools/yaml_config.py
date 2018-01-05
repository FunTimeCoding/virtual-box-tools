from os.path import expanduser, isfile

from yaml import load_all, dump


class YamlConfig:
    def __init__(self, path: str = ''):
        self.settings = {}
        self.path = expanduser(path)

        if self.exists():
            input_file = open(self.path, 'r')
            elements = load_all(input_file)

            for dictionary in elements:
                for key, value in dictionary.items():
                    self.settings[key] = value

            input_file.close()

    def exists(self) -> bool:
        result = False

        if isfile(self.path):
            result = True

        return result

    def contains(self, key: str) -> bool:
        result = False

        if key in self.settings:
            result = True

        return result

    def get(self, key: str) -> str:
        return self.settings.get(key, '')

    def set(self, key: str, value: str):
        self.settings[key] = value

    def remove(self, key: str) -> str:
        return self.settings.pop(key, None)

    def save(self) -> None:
        output_file = open(self.path, 'w')
        output_file.write(dump(self.settings, default_flow_style=False))
        output_file.close()
