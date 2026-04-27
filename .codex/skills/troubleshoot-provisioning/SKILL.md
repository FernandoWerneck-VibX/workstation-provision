---
name: troubleshoot-provisioning
description: Diagnose and fix failures from bootstrap.sh or ansible-playbook runs in the workstation-provision repository. Use when Codex needs to inspect failed roles or tasks, apt or Flatpak issues, SDKMAN/NVM/uv problems, rclone/systemd failures, or validation errors.
---

# Troubleshoot Provisioning

Use esta skill para diagnosticar falhas no bootstrap ou no playbook.

## Primeiros Passos

1. Identifique a role e a task que falhou.
2. Rode novamente com mais detalhe:

```bash
ansible-playbook -i inventory.ini site.yml --ask-become-pass -vv
```

3. Valide sintaxe local:

```bash
make check
```

## Fontes Comuns

- `apt`: repositorio externo, chave GPG, pacote indisponivel.
- `flatpak`: Flathub ausente, app ID incorreto.
- `nvm`: shell nao carregou `nvm.sh`.
- `sdkman`: rede ou versao Java indisponivel.
- `uv`: PATH do usuario incompleto.
- `systemd`: unit alterada sem daemon reload.
- `rclone`: remote `gdrive` ainda nao configurado.

## Saida Esperada

Ao responder, inclua:

- task que falhou
- causa provavel
- comando de reproducao
- patch ou ajuste recomendado
