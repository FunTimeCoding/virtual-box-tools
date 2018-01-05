from virtual_box_tools.virtual_box_tools import Commands


def test_password_length() -> None:
    assert len(Commands.generate_password()) is 14
