from virtual_box_tools.command_process import CommandProcess, \
    CommandFailed


def test_standard_output() -> None:
    process = CommandProcess(['echo', 'example'])
    assert process.get_standard_output() == 'example'
    assert process.get_standard_error() == ''
    assert process.get_return_code() == 0


def test_standard_error() -> None:
    process = CommandProcess(['tests/standard-error.sh'])
    assert process.get_standard_output() == ''
    assert process.get_standard_error() == 'error'
    assert process.get_return_code() == 0


def test_exit_code() -> None:
    try:
        CommandProcess(['tests/exit.sh'])
        assert False
    except CommandFailed as exception:
        assert exception.get_standard_output() == ''
        assert exception.get_standard_error() == ''
        assert exception.get_return_code() == 1


def test_standard_output_error_and_exit_code() -> None:
    try:
        CommandProcess(['tests/standard-output-error-and-exit.sh'])
        assert False
    except CommandFailed as exception:
        assert exception.get_standard_output() == 'example'
        assert exception.get_standard_error() == 'error'
        assert exception.get_return_code() == 2


def test_long_process() -> None:
    process = CommandProcess(['sleep', '1'])
    assert process.get_standard_output() == ''
    assert process.get_standard_error() == ''
    assert process.get_return_code() == 0
