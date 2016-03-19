from virtual_box_tools.host_config_main import HostConfigMain


def test_return_code() -> None:
    application = HostConfigMain([])
    assert application.run() == 0
