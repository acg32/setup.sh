SHELL := /bin/sh
PATH := $(HOME)/.local/bin:$(PATH)

.PHONY: bootstrap ansible-collections ansible-base ansible-ux ansible-workloads ansible-personal dotfiles verify setup install report

ANSIBLE := ansible-playbook --ask-become-pass -e user=$(USER) -i ansible/inventory.ini

bootstrap:
	./scripts/bootstrap.sh

ansible-collections:
	ansible-galaxy collection install -r ansible/requirements.yml

ansible-base: ansible-collections
	$(ANSIBLE) ansible/playbook-base.yaml

ansible-ux: ansible-collections
	$(ANSIBLE) ansible/playbook-ux.yaml

ansible-workloads: ansible-collections
	$(ANSIBLE) ansible/playbook-workloads.yaml

ansible-personal: ansible-collections
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
