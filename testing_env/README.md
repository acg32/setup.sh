# Testing environment

Testing environment for setup automation.

Inspired from https://github.com/Imoustak/ansible_intro

## Using the env

```Shell
# Start VM ubu24_test
vagrant up
# Check status
vagrant status
# SSH to it
vagrant ssh ubu24_test
# Stop the VM
vagrant halt
```

## Validate Ansible
```Shell
ansible-playbook -i hosts ../ansible/playbook-local.yaml --ask-become-pass -e user=$USER
```
