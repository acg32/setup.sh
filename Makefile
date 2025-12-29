SHELL := /bin/sh

.PHONY: bootstrap ansible-base ansible-ux ansible-workloads ansible-personal dotfiles verify

ANSIBLE := ansible-playbook --ask-become-pass -e user=$(USER) -i ansible/inventory.ini

bootstrap:
	./bootstrap.sh

ansible-base:
	$(ANSIBLE) ansible/playbook-base.yaml

ansible-ux:
	$(ANSIBLE) ansible/playbook-ux.yaml

ansible-workloads:
	$(ANSIBLE) ansible/playbook-workloads.yaml

ansible-personal:
	$(ANSIBLE) ansible/playbook-personal.yaml

dotfiles:
	$(MAKE) -C dotfiles install

verify:
	$(MAKE) -C dotfiles verify
