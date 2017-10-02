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
        token = ''

        if authorization_header != '':
            authorization = str(request.headers.get('Authorization')).split(' ')

            if len(authorization) is 2:
                authorization_type = authorization[0]
                token = authorization[1]

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
            return authorization_result

        status_code = 200

        if request.method == 'GET':
            if name == '':
                body = json.dumps([{
                    'name': 'example',
                    'virtual_address': '127.0.0.1',
                    'physical_address': '00:00:00:00:00',
                    'services': []
                }])
            else:
                process = CommandProcess(
                    arguments=[
                        'vboxmanage', 'guestproperty', 'enumerate', name
                    ],
                    sudo_user=WebService.sudo_user
                )
                return_code = process.get_return_code()
                standard_output = process.get_standard_output()
                standard_error = process.get_standard_error()

                if return_code is 0:
                    body = json.dumps({
                        'virtual_address': '127.0.0.1',
                        'physical_address': '00:00:00:00:00',
                        'services': []
                    })
                else:
                    if 'Could not find a registered machine named' \
                            in standard_error:
                        status_code = 404
                        body = json.dumps({
                            'message': 'Host not found.',
                        })
                    else:
                        status_code = 500
                        body = json.dumps({
                            'name': name,
                            'standard_output': standard_output,
                            'standard_error': standard_error,
                            'return_code': return_code
                        })

        elif request.method == 'POST':
            body = 'Host created: ' + str(request.json.get('name'))
        else:
            status_code = 500
            body = 'Unexpected method: ' + request.method

        return body, status_code
