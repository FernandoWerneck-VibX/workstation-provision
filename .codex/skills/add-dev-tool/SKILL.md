---
name: add-dev-tool
description: Add or update developer tools, languages, CLIs, or shell integrations in the workstation-provision repository. Use when Codex needs to modify dev_tools, devops, shell, shell_env, check-env, or language/tool version defaults.
---

# Add Dev Tool

Use esta skill ao adicionar linguagens, CLIs ou ferramentas de desenvolvimento.

## Workflow

1. Leia `roles/dev_tools/tasks/main.yml`.
2. Verifique se a ferramenta pertence a `dev_tools`, `devops`, `shell` ou
   `desktop_apps`.
3. Adicione versoes configuraveis em defaults quando fizer sentido.
4. Instale ferramentas Python com `uv tool install` quando aplicavel.
5. Instale ferramentas Node no ambiente NVM quando aplicavel.
6. Exporte PATH ou completions em `shell_env` quando isso for necessario.
7. Atualize `utils-scripts/system/check-env.sh` se a ferramenta for essencial.
8. Rode `make check` e `make lint`.

## Riscos

- Instaladores remotos precisam ser idempotentes.
- Evite misturar gerenciadores para a mesma familia de ferramenta.
- Ferramentas globais devem funcionar para `dev_user`, nao apenas para root.
