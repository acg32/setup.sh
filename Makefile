SHELL := /bin/sh
PATH := $(HOME)/.local/bin:$(PATH)

.PHONY: bootstrap ansible-base ansible-ux ansible-workloads ansible-personal dotfiles verify setup install report

ANSIBLE := ansible-playbook --ask-become-pass -e user=$(USER) -i ansible/inventory.ini

bootstrap:
	./scripts/bootstrap.sh

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

report:
	./scripts/system_report.sh

setup:
	@command -v uv >/dev/null 2>&1 || { \
		echo "uv not found. Run 'make install' or './scripts/bootstrap.sh' first."; \
		exit 1; \
	}
	./scripts/setup.py

install:
	./scripts/bootstrap.sh
	$(MAKE) setup
