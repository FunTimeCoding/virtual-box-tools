import ctypes


def getpwnam(user: str):
    get_user_name = ctypes.windll.secur32.GetUserNameExW
    display_name = 3
    size = ctypes.pointer(ctypes.c_ulong(0))
    get_user_name(display_name, None, size)
    name_buffer = ctypes.create_unicode_buffer(size.contents.value)
    get_user_name(display_name, name_buffer, size)

    return ['', '', '', '', name_buffer.value]
