import logging
from sys import argv

from flask import Flask, request, json

from virtual_box_tools.command_process import CommandProcess, CommandFailed
from virtual_box_tools.virtual_box_tools import Commands
from virtual_box_tools.yaml_config import YamlConfig


class WebService:
    app = Flask(__name__)
    token = None
    sudo_user = None

    def __init__(self, arguments: list):
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        config = YamlConfig('~/.virtual-box-tools.yaml')
        WebService.token = config.get('token')
        WebService.sudo_user = config.get('sudo_user')
        self.listen_address = config.get('listen_address')

    @staticmethod
    def main() -> int:
        return WebService(argv[1:]).run()

    def run(self) -> int:
        # Avoid triggering a reload. Otherwise stats gets loaded after a
        # restart, which leads to two competing updater instances.
        self.app.run(
            host=self.listen_address,
            use_reloader=False
        )

        return 0

    @staticmethod
    def authorize():
        header = str(request.headers.get('Authorization'))
        authorization_type = ''
        token = ''

        if header != '':
            elements = header.split(' ')

            if len(elements) is 2:
                authorization_type = elements[0]
                token = elements[1]

        if token != WebService.token \
                or authorization_type != 'Token':
            return 'Authorization failed.'

        return ''

    @staticmethod
    @app.route('/host', methods=['GET'])
    @app.route('/host/<name>', methods=['GET', 'POST'])
    def register_object(name: str = ''):
        authorization_result = WebService.authorize()

        if authorization_result != '':
            return authorization_result, 401

        status_code = 200

        if request.method == 'GET':
            commands = Commands(WebService.sudo_user)

            if name == '':
                try:
                    body = json.dumps(commands.list_virtual_machines())
                except CommandFailed as exception:
                    status_code = 500
                    body = json.dumps({
                        'standard_output': exception.get_standard_output(),
                        'standard_error': exception.get_standard_error(),
                        'return_code': exception.get_return_code()
                    })
            else:
                try:
                    body = json.dumps(
                        commands.get_virtual_machine_information(name=name)
                    )
                except CommandFailed as exception:
                    if 'Could not find a registered machine named' \
                            in exception.get_standard_error():
                        status_code = 404
                        body = json.dumps({
                            'message': 'Host not found.',
                        })
                    else:
                        status_code = 500
                        body = json.dumps({
                            'standard_output': exception.get_standard_output(),
                            'standard_error': exception.get_standard_error(),
                            'return_code': exception.get_return_code()
                        })

        elif request.method == 'POST':
            body = 'Host created: ' + str(request.json.get('name'))
        else:
            status_code = 500
            body = 'Unexpected method: ' + request.method

        return body, status_code
