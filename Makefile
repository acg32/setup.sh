SHELL := /bin/sh
PATH := /opt/homebrew/bin:/usr/local/bin:$(HOME)/.local/bin:$(PATH)
UNAME_S ?= $(shell uname -s)

.PHONY: bootstrap ansible-collections ansible-base ansible-ux ansible-workloads ansible-personal ansible-vm brew-base brew-ux brew-workloads brew-personal dotfiles verify setup install report

# Prompt for sudo unless passwordless sudo works, or ASK_BECOME=0 is set.
ASK_BECOME ?= $(shell sudo -n true >/dev/null 2>&1 && echo 0 || echo 1)
ANSIBLE_BECOME_FLAG := $(if $(filter 1,$(ASK_BECOME)),--ask-become-pass,)
ANSIBLE := ansible-playbook $(ANSIBLE_BECOME_FLAG) -e user=$(USER) -i ansible/inventory.ini

bootstrap:
ifeq ($(UNAME_S),Darwin)
	./scripts/bootstrap-macos.sh
else ifeq ($(UNAME_S),Linux)
	./scripts/bootstrap.sh
else
	@echo "Unsupported operating system: $(UNAME_S)" >&2
	@exit 1
endif

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

ansible-vm: ansible-collections
	$(ANSIBLE) ansible/playbook-vm.yaml

brew-base:
	brew bundle --file=macos/Brewfile.base

brew-ux:
	brew bundle --file=macos/Brewfile.ux

brew-workloads:
	brew bundle --file=macos/Brewfile.workloads

brew-personal:
	brew bundle --file=macos/Brewfile.personal

dotfiles:
ifeq ($(UNAME_S),Darwin)
	$(MAKE) -C dotfiles macos
else
	$(MAKE) -C dotfiles install
endif

verify:
	$(MAKE) -C dotfiles verify

report:
	./scripts/system_report.sh

setup:
	@command -v uv >/dev/null 2>&1 || { \
		echo "uv not found. Run 'make install' or 'make bootstrap' first."; \
		exit 1; \
	}
	./scripts/setup.py

install: bootstrap
	$(MAKE) setup
