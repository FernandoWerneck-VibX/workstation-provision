# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A **local Ansible playbook** that provisions a Linux Mint 22.x (Cinnamon, Ubuntu 24.04 base) developer workstation from a fresh install. Treat changes as OS automation: a small edit to a role can have broad, hard-to-reverse effects on the user's machine. Prefer the smallest change that satisfies the request, and read the affected role before editing it.

Project docs are written in Portuguese. The canonical agent-facing guidance is `AGENTS.md` and `docs/ARCHITECTURE.md` — read them before substantial edits.

## Commands

Run these before finishing any change:

```bash
make check      # bash -n on all shell scripts + ansible-playbook --syntax-check
make lint       # pre-commit run --all-files (bash-syntax, yamllint, ansible-lint)
```

Other useful targets:

```bash
make lint-yaml                    # yamllint .
make lint-ansible                 # ansible-lint
make dry-run PROFILE=personal.yml # ansible-playbook --check (may require sudo)
make install PROFILE=personal.yml # runs ./bootstrap.sh <profile>
make verify                       # runs utils-scripts/system/check-env.sh
```

Run the playbook directly (the profile is applied as extra vars):

```bash
ansible-playbook -i inventory.ini site.yml --ask-become-pass
ansible-playbook -i inventory.ini site.yml --ask-become-pass -e @profiles/personal.yml
```

There is **no unit-test suite**. The validation loop for an iterating change is `make check` (fast) → `make lint` → `make dry-run` (full `--check` simulation). `inventory.ini` pins the interpreter to `/usr/bin/python3` so runs don't depend on the user's `pyenv`/`uv`.

## Architecture

**Single play, ordered roles.** `site.yml` runs one play (`hosts: local`, `become: yes`) that applies every role in a fixed order; order encodes dependencies (e.g. `dev_tools` installs NVM before `openclaw` installs an npm package into it; `cleanup_apps` and `onboarding` run last). Optional roles are gated with `when: <flag>_enable | default(true)` — `openclaw`, `projects`, `ai_assistant`, `syncthing`, `gdrive`.

**Variable precedence (low → high):** `roles/<role>/defaults/main.yml` → `group_vars/all.yml` → `profiles/*.yml` (passed via `-e @profiles/...`). Profiles are thin: they only flip the `*_enable` toggles and set personal data (e.g. `projects_repos`). `profiles/personal.yml` keeps personal services on; `profiles/collaborator.yml` turns them off.

**Never hardcode the user, home, or personal paths.** `dev_user`/`dev_home` are auto-detected in `group_vars/all.yml` from `SUDO_USER`/`USER`. Use `dev_user`, `dev_home`, `projects_dir`, and equivalent variables. User-level tasks must run with `become_user: "{{ dev_user }}"`; system-level tasks rely on the play's `become: yes`.

**Role shape (keep minimal):** `defaults/main.yml` for public/configurable values, `tasks/main.yml` for orchestration, `templates/*.j2` when content has Ansible variables, `handlers/main.yml` only when a service must restart on template change.

**Desktop apps are data-driven.** `roles/desktop_apps/defaults/main.yml` declares `desktop_apps_catalog` (a list of app entries); `tasks/install_single_app.yml` is the generic engine that, per entry, prefers Flatpak and falls back to a declarative native installer (`apt`/`deb`/`tarball`/apt-repo with GPG key handling). Set `flatpak_preferred: false` to force the native path (VS Code, IntelliJ). To add/remove an app, edit the catalog data — don't add bespoke tasks. `roles/cleanup_apps` removes unwanted apt packages (`cleanup_apps_packages`) and flatpaks (`cleanup_apps_flatpaks`) at the end.

**Two layers of AI-agent context.** (1) Repo-level: `AGENTS.md`, `docs/`, `.codex/skills/`, `.cursor/rules/`, `.github/copilot-instructions.md`. (2) Provisioned onto the machine by `roles/ai_assistant`, which renders `~/.ai-assistant/` (AGENTS/WORKFLOWS/SAFETY/PROJECTS/SKILLS + versioned skills). Its optional "project pack" (`ai_assistant_project_pack_enable`, off by default) seeds guidance files into cloned repos with `force: false`. `roles/openclaw` installs the OpenClaw local assistant (npm under NVM + a systemd `openclaw-gateway` service).

`utils-scripts/` holds standalone helper scripts grouped by area (system/docker/k8s/dev/git/gdrive); they are operator conveniences, not part of the provisioning run.

## Editing rules specific to this repo

- **Preserve idempotency.** `shell`/`command` tasks need `creates:`, `changed_when:`, `failed_when:`, or a pre-check guard. Use `handlers` to restart services when a template changes.
- **snapd is removed and blocked** by the `common` role — do not introduce `snap`-based installs.
- Keep configurable values in the relevant `defaults/main.yml`; use `group_vars/all.yml` only for defaults that cross roles.
- Don't remove existing functionality without a clear reason. No secrets, tokens, or private keys in the repo.
