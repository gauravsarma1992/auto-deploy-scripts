#!/bin/bash

PLAYBOOK_FOLDER=./playbooks

cd $PLAYBOOK_FOLDER
ansible-playbook init-playbook.yml -f 10
ansible-playbook install-kubectl.yml -f 10
