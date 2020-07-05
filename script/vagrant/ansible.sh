#!/bin/sh -e

export ANSIBLE_RETRY_FILES_ENABLED=0
ansible-playbook --diff --inventory /vagrant/inventory /vagrant/playbook.yaml
