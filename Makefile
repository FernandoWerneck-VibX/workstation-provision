SHELL := /bin/bash

.PHONY: install check syntax lint lint-yaml lint-ansible dry-run verify

PROFILE ?=
ANSIBLE_PROFILE_ARG := $(if $(PROFILE),-e @profiles/$(PROFILE),)

install:
	./bootstrap.sh $(PROFILE)

syntax:
	bash -n bootstrap.sh
	find utils-scripts roles -type f -name '*.sh' -print0 | xargs -0 -r -n1 bash -n
	ansible-playbook -i inventory.ini site.yml --syntax-check

check: syntax

lint:
	pre-commit run --all-files

lint-yaml:
	yamllint .

lint-ansible:
	ansible-lint

dry-run:
	ansible-playbook -i inventory.ini site.yml --ask-become-pass --check $(ANSIBLE_PROFILE_ARG)

verify:
	./utils-scripts/system/check-env.sh
