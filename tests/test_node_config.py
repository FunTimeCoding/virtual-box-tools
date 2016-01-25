from virtual_box_tools.node_config_main import NodeConfigMain


def test_return_code():
    application = NodeConfigMain([])
    assert application.run() == 0
