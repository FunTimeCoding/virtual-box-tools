from virtual_box_tools.scan_code import ScanCode


def test_single_letter() -> None:
    assert ScanCode.scan('a') == '1e 9e'


def test_two_letters() -> None:
    assert ScanCode.scan('ab') == '1e 9e 30 b0'


def test_newline() -> None:
    assert ScanCode.scan('\n') == '1c 9c'


def test_escape() -> None:
    assert ScanCode.scan('\027') == '01 81'


def test_two_letters_with_newline() -> None:
    assert ScanCode.scan('a\nb') == '1e 9e 1c 9c 30 b0'


def test_installer_command() -> None:
    assert ScanCode.scan(
        'auto url=http://127.0.0.1:8000/example.cfg'
    ) == '1e 9e 16 96 14 94 18 98 39 b9 16 96 13 93 26 a6\n\
0d 8d 23 a3 14 94 14 94 19 99 2a 27 a7 aa 35 b5\n\
35 b5 02 82 03 83 08 88 34 b4 0b 8b 34 b4 0b 8b\n\
34 b4 02 82 2a 27 a7 aa 09 89 0b 8b 0b 8b 0b 8b\n\
35 b5 12 92 2d ad 1e 9e 32 b2 19 99 26 a6 12 92\n\
34 b4 2e ae 21 a1 22 a2'


def test_split_lines() -> None:
    assert ScanCode.scan(
        '123456789'
    ).splitlines() == [
               '02 82 03 83 04 84 05 85 06 86 07 87 08 88 09 89',
               '0a 8a'
           ]
