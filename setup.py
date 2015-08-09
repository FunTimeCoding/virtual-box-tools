try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

setup(
    name='virtualbox-tools',
    version='0.1',
    description='Stub description for virtualbox-tools.',
    packages=['virtualbox_tools'],
    author='Alexander Reitzel',
    author_email='funtimecoding@gmail.com',
    url='http://example.org',
    download_url='http://example.org/virtualbox-tools.tar.gz',
    install_requires=['pyyaml'],
    scripts=['bin/node-config']
)
