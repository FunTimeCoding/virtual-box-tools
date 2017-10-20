#!/usr/bin/env python3
from setuptools import setup

setup(
    name='virtual-box-tools',
    version='0.1.0',
    description='Manage VirtualBox virtual machines from command line and'
                ' a web service',
    url='https://github.com/FunTimeCoding/virtual-box-tools',
    author='Alexander Reitzel',
    author_email='funtimecoding@gmail.com',
    license='MIT',
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'Intended Audience :: System Administrators',
        'License :: OSI Approved :: MIT License',
        'Natural Language :: English',
        'Operating System :: MacOS :: MacOS X',
        'Operating System :: POSIX :: Linux',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: 3.5',
        'Programming Language :: Python :: 3.6',
        'Topic :: Software Development',
        'Topic :: System :: Clustering',
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
            'HostConfiguration.main',
            'vbt-web-service=virtual_box_tools.web_service:'
            'WebService.main',
        ],
    },
)
