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
13. `auto_updates`: `unattended-upgrades` e timer de reaplicacao do playbook.
14. `cleanup_apps`: remocao de aplicativos indesejados.
15. `onboarding`: checklist final em `~/WORKSTATION_ONBOARDING.md`.

Cada role tem uma tag com o proprio nome em `site.yml`, o que permite execucao
parcial via `--tags`/`--skip-tags` (usado tambem pelo timer de self-update).

## Atualizacao Automatica

O projeto assume que nada instalado deve exigir uma re-execucao manual do
bootstrap. Tres camadas cobrem os tres tipos de instalacao que existem aqui:

- **Flatpak** (`roles/desktop_apps`): `flatpak-update.timer`, diario e no boot.
- **apt** (`roles/auto_updates`): `unattended-upgrades` com `Origins-Pattern`
  aberto, porque os patterns default do Ubuntu so liberam os repos oficiais e
  deixariam VS Code, Docker e GitHub CLI parados.
- **Resto** (`roles/auto_updates`): `workstation-selfupdate.timer` reexecuta o
  proprio playbook. Isso funciona porque as roles resolvem "latest" em tempo de
  execucao — binarios em `/usr/local/bin`, tarballs em `/opt`, AWS CLI, npm
  globais, uv, ble.sh e afins ja se atualizam a cada run.

Consequencia pratica ao escrever tasks: **`creates:` congela a versao**. Se um
componente precisa acompanhar upstream, a task tem que ter um caminho de
atualizacao (comparacao de versao, `self update`/`upgrade` do proprio binario ou
reinstalacao idempotente), nao apenas um guard de existencia. Versoes pinadas em
variaveis (`java_version`, `python_version`, `node_version`, `nvm_version`) sao
excecao deliberada.

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
