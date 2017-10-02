import logging
from sys import argv

from flask import Flask, request, json

from virtual_box_tools.command_process import CommandProcess
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
        authorization_header = str(request.headers.get('Authorization'))
        authorization_type = ''
        authorization_token = ''

        if authorization_header != '':
            authorization = str(request.headers.get('Authorization')).split(' ')

            if len(authorization) is 2:
                authorization_type = authorization[0]
                authorization_token = authorization[1]

        if authorization_token != WebService.token \
                or authorization_type != 'Token':
            return 'Authorization failed.'

        return ''

    @staticmethod
    @app.route('/host/<name>', methods=['GET', 'POST'])
    def register_object(name: str):
        authorization_result = WebService.authorize()

        if authorization_result != '':
            return authorization_result

        if request.method == 'GET':
            if name == '':
                body = json.dumps([{
                    'name': 'example',
                    'virtual_address': '127.0.0.1',
                    'physical_address': '00:00:00:00:00',
                    'services': []
                }])
            else:
                process = CommandProcess([
                    # 'echo example',
                    # 'sleep 10',
                    # 'exit 1',
                    'echo error 1>&2',
                    # 'sudo', '-u', WebService.sudo_user,
                    # 'vboxmanage', 'guestproperty', 'enumerate', name
                ])
                exit_code = process.get_exit_code()
                standard_output = process.get_standard_output()
                standard_error = process.get_error_output()

                if exit_code is 0:
                    # body = json.dumps({
                    #     'name': name,
                    #     'virtual_address': '127.0.0.1',
                    #     'physical_address': '00:00:00:00:00',
                    #     'services': []
                    # })
                    body = standard_output + standard_error
                else:
                    body = 'something went wrong: ' + str(exit_code) + ' ' \
                           + standard_output + ' ' + standard_error

        elif request.method == 'POST':
            body = 'Host created: ' + str(request.json.get('name'))
        else:
            body = 'Unexpected method: ' + request.method

        return body
