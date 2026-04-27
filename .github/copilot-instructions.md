# Copilot Instructions

This repository provisions a Linux Mint workstation with Ansible.

Follow these rules:

- read `AGENTS.md` before making changes
- prefer existing role patterns
- keep Ansible tasks idempotent
- do not add secrets, tokens or private keys
- use `dev_user`, `dev_home` and existing variables for user paths
- validate with `make check`
- run `make lint` when the local tools are available

Important paths:

- `site.yml`: role order
- `group_vars/all.yml`: global defaults
- `profiles/`: machine profiles
- `roles/ai_assistant`: AI context and project readiness pack
- `.codex/skills`: local coding-agent workflows

