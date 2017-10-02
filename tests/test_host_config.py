from virtual_box_tools.host_configuration import HostConfiguration


def test_return_code() -> None:
    application = HostConfiguration([])
    assert application.run() == 0
