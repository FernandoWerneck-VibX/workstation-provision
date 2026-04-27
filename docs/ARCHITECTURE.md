# Arquitetura

Este projeto e um playbook Ansible local para transformar uma instalacao nova
do Linux Mint em uma workstation de desenvolvimento.

## Fluxo Principal

O arquivo `site.yml` aplica as roles nesta ordem:

1. `common`: base do sistema, pacotes essenciais e ajustes operacionais.
2. `cinnamon`: ajustes especificos do desktop Cinnamon.
3. `shell_env`: estrutura modular de shell em `~/.bashrc.d`.
4. `shell`: Git, aliases, prompt e produtividade no terminal.
5. `dev_tools`: Java, Node, Python, Flutter e linters.
6. `devops`: Docker, Compose, kubectl, helm, kind e k9s.
7. `openclaw`: instalacao do assistente local OpenClaw.
8. `desktop_apps`: catalogo de aplicativos desktop.
9. `projects`: clonagem de repositorios.
10. `ai_assistant`: contexto, skills e preparo opcional dos repositorios.
11. `syncthing`: sincronizacao local opcional.
12. `gdrive`: Google Drive via `rclone` opcional.
13. `cleanup_apps`: remocao de aplicativos indesejados.
14. `onboarding`: checklist final em `~/WORKSTATION_ONBOARDING.md`.

## Variaveis

- Defaults globais ficam em `group_vars/all.yml`.
- Defaults especificos de role ficam em `roles/<role>/defaults/main.yml`.
- Perfis em `profiles/` sobrescrevem os defaults para cenarios concretos.
- Evite duplicar defaults entre perfil e role sem necessidade.

## Padrao de Role

Cada role deve manter a menor superficie possivel:

- `defaults/main.yml` para configuracao publica.
- `tasks/main.yml` para orquestracao.
- `templates/` quando o conteudo tiver variaveis Ansible.
- `handlers/main.yml` apenas quando houver servico a reiniciar.

## AI Readiness

O projeto possui duas camadas para trabalho com agentes:

- Contexto do proprio repositorio: `AGENTS.md`, `docs/` e `.codex/skills/`.
- Contexto provisionado na maquina: `roles/ai_assistant`.

O role `ai_assistant` copia instrucoes, workflows e skills para
`~/.ai-assistant` e, opcionalmente, prepara projetos clonados com arquivos de
orientacao (`AGENTS.md`, `.github/copilot-instructions.md` e regras do Cursor).

## Validacao

O caminho padrao de validacao e:

```bash
make check
make lint
```

Use `make dry-run PROFILE=personal.yml` para uma simulacao do playbook.
