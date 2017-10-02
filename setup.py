# !/usr/bin/env python3
from setuptools import setup

setup(
    name='virtual-box-tools',
    version='0.1.0',
    description='Manage VirtualBox virtual machines from command line and '
                'a web service',
    url='https://github.com/FunTimeCoding/virtual-box-tools',
    author='Alexander Reitzel',
    author_email='funtimecoding@gmail.com',
    license='MIT',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: System Administrators',
        'Intended Audience :: Developers',
        'Topic :: System :: Clustering',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
    ],
    keywords='virtualbox abstraction command line web service',
    packages=['virtual_box_tools'],
    install_requires=['pyyaml', 'flask'],
    python_requires='>=3.2',
    entry_points={
        'console_scripts': [
            'vbt=virtual_box_tools.virtual_box_tools:'
            'VirtualBoxTools.main',
            'vbt-host-configuration=virtual_box_tools.host_configuration:'
            'HostConfig.main',
            'vbt-web-service=virtual_box_tools.web_service:'
            'WebService.main',
        ],
    },
)
