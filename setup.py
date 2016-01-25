#!/usr/bin/env python3
from setuptools import setup

setup(
    name='virtual-box-tools',
    version='0.1',
    description='Stub description for virtual-box-tools.',
    install_requires=['pyyaml', 'python-utility'],
    scripts=['bin/node_config'],
    packages=['virtual_box_tools'],
    author='Alexander Reitzel',
    author_email='funtimecoding@gmail.com',
    url='http://example.org',
    download_url='http://example.org/virtual-box-tools.tar.gz'
)
