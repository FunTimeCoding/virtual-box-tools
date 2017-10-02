from flask import Flask, request, json

from virtual_box_tools.command_process import CommandProcess
from virtual_box_tools.yaml_config import YamlConfig


class WebService:
    app = Flask(__name__)
    token = None
    sudo_user = None

    def __init__(self, arguments: list):
        config = YamlConfig('~/.virtual-box-tools.yaml')
        WebService.token = config.get('token')
        WebService.sudo_user = config.get('sudo_user')
        self.listen_address = config.get('listen_address')

    def main(self) -> int:
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
    @app.route('/host', methods=['GET', 'POST'])
    def register_object():
        authorization_result = WebService.authorize()

        if authorization_result != '':
            return authorization_result

        if request.method == 'GET':
            body = json.dumps([{
                'name': 'example',
                'virtual_address': '127.0.0.1',
                'physical_address': '00:00:00:00:00',
                'services': []
            }])
        elif request.method == 'POST':
            body = 'Host created: ' + str(request.json.get('name'))
        else:
            body = 'Unexpected method: ' + request.method

        return body

    @staticmethod
    @app.route('/host/<name>', methods=['GET'])
    def register_object(name: str):
        authorization_result = WebService.authorize()

        if authorization_result != '':
            return authorization_result

        process = CommandProcess([
            'sudo', '-u', WebService.sudo_user,
            'vboxmanage', 'guestproperty', 'enumerate', name
        ])
        exit_code = process.get_exit_code()

        if exit_code is 0:
            output = process.get_standard_output()
            # body = json.dumps({
            #     'name': name,
            #     'virtual_address': '127.0.0.1',
            #     'physical_address': '00:00:00:00:00',
            #     'services': []
            # })
            body = output
        else:
            body = '', 500

        return body
