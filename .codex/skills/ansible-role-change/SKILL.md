---
name: ansible-role-change
description: Change or create Ansible roles in the workstation-provision repository. Use when Codex needs to modify role tasks, defaults, templates, handlers, role ordering, idempotent provisioning behavior, or Ansible validation flows in this project.
---

# Ansible Role Change

Use esta skill ao alterar ou criar roles neste projeto.

## Workflow

1. Leia `AGENTS.md` e `docs/ARCHITECTURE.md`.
2. Abra `site.yml` para confirmar a ordem das roles.
3. Leia `roles/<role>/defaults/main.yml` e `roles/<role>/tasks/main.yml`.
4. Coloque novas opcoes configuraveis em defaults.
5. Mantenha tarefas idempotentes com modulo Ansible sempre que possivel.
6. Atualize README ou onboarding quando o comportamento mudar.
7. Rode `make check` e, se disponivel, `make lint`.

## Padroes

- Use `dev_user` e `dev_home` para caminhos do usuario.
- Use `become_user: "{{ dev_user }}"` para comandos no ambiente do usuario.
- Use templates para arquivos com variaveis.
- Use handlers para reiniciar servicos afetados por templates.
- Evite shell quando um modulo Ansible resolver com clareza.

## Riscos

- Mudancas em roles iniciais podem afetar todo o provisionamento.
- Downloads externos devem ter validacao ou mensagem de falha clara.
- Tarefas destrutivas precisam ser explicitamente opt-in.
