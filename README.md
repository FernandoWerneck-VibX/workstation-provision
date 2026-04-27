# Fernando Workstation

Provisionamento de workstation para Linux Mint 22.x (Cinnamon) com Ansible.

Objetivo: pegar uma maquina nova e sair com sistema, shell, ferramentas de desenvolvimento, apps desktop e servicos opcionais prontos, com suporte a perfis pessoal e colaborador.
O projeto tambem prepara contexto local para uso de agentes de IA no auxilio a
programacao.

## Escopo

- Linux Mint 22.x baseado em Ubuntu 24.04
- Execucao local via Ansible
- Perfis prontos em `profiles/`
- Roles separadas para sistema, shell, dev tools, DevOps, apps desktop, projetos e integracoes opcionais

## O que o projeto instala

### Sistema base

- atualizacao do sistema via `apt`
- pacotes essenciais como `git`, `curl`, `wget`, `vim`, `build-essential`, `htop`, `btop`, `fzf`, `fd`, `ripgrep`, `bat`, `jq`, `gawk`, `copyq`
- codecs do Linux Mint (`mint-meta-codecs`)
- `flatpak` com Flathub
- `snapd` removido e bloqueado
- `zram`, `irqbalance` e `fstrim.timer`
- `tlp` apenas em notebooks
- `tlp-pd` quando disponivel no repositrio
- `gTile` via Cinnamon Spices

### Shell e produtividade

- Bash modular via `~/.bashrc.d`
- `bash-git-prompt`
- `ble.sh`
- `atuin`
- `gcalendar` no perfil pessoal com fallback para `uv tool install`
- `pay-respects`
- OpenClaw como assistente pessoal local (`gateway` + dashboard + workspace dedicado)
- contexto local para agentes de IA em `~/.ai-assistant`
- skills locais para rotinas recorrentes de desenvolvimento e provisionamento
- completions e integracoes do Git
- aliases via `chezmoi/dot_bash_aliases`

### Desenvolvimento

- Java via SDKMAN
- Node.js via NVM
- Python via `uv`
- ferramentas Python via `uv tool install`
- `pre-commit`, `yamllint`, `ansible-lint`
- Flutter SDK

### DevOps

- Docker Engine + Compose plugin
- `kubectl`
- `helm`
- `kind`
- `k9s`

### Apps desktop

Catalogo atual em [roles/desktop_apps/defaults/main.yml](/home/fernando/projects/vib/workstation-provision/roles/desktop_apps/defaults/main.yml):

- Chrome
- Firefox
- VS Code
- IntelliJ IDEA Ultimate
- Sublime Text
- Obsidian
- Postman
- Discord
- Spotify
- Ferdium
- Snapshot
- SSH Pilot
- Audiotube
- Celluloid
- gThumb

Observacoes:
- o projeto prioriza Flatpak para apps desktop, com fallback nativo quando necessario
- VS Code usa repositorio oficial da Microsoft
- IntelliJ IDEA Ultimate usa download oficial da JetBrains

### Integracoes opcionais

- Syncthing
- Google Drive via `rclone`
- OpenClaw como assistente pessoal local
- AI assistant context independente de ferramenta (`~/.ai-assistant`)
- Google Calendar desklet no perfil pessoal
- Cinnamon Dynamic Wallpaper no perfil pessoal
- aplicacao de dotfiles via `chezmoi`
- clonagem automatica de projetos Git

## Perfis

Perfis disponiveis:

- [profiles/personal.yml](/home/fernando/projects/vib/workstation-provision/profiles/personal.yml): mantem Syncthing, Google Drive, OpenClaw e clonagem de projetos ativos
- [profiles/collaborator.yml](/home/fernando/projects/vib/workstation-provision/profiles/collaborator.yml): desativa recursos pessoais

## Como executar

### 1. Clonar o repositorio

```bash
git clone <repo>
cd workstation-provision
```

### 2. Ajustar variaveis obrigatorias

Revise [group_vars/all.yml](/home/fernando/projects/vib/workstation-provision/group_vars/all.yml):

- `git_user_name`
- `git_user_email`
- `chezmoi_repo` se quiser usar um repo remoto de dotfiles
- `projects_repos` se quiser definir uma lista global de repositorios clonados

`dev_user` e `dev_home` sao resolvidos automaticamente a partir do usuario que executa o playbook.

### 3. Rodar o bootstrap

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

O script:

1. exige execucao com usuario comum
2. permite escolher um perfil interativamente
3. instala `ansible` e `git`
4. roda o playbook principal

Tambem funciona com argumento explicito:

```bash
./bootstrap.sh collaborator.yml
```

### 4. Rodar direto com Ansible

```bash
ansible-playbook -i inventory.ini site.yml --ask-become-pass
ansible-playbook -i inventory.ini site.yml --ask-become-pass -e @profiles/personal.yml
ansible-playbook -i inventory.ini site.yml --ask-become-pass -e @profiles/collaborator.yml
```

O inventario local esta em [inventory.ini](/home/fernando/projects/vib/workstation-provision/inventory.ini) e fixa o interpretador em `/usr/bin/python3` para nao depender de `pyenv` ou ferramentas do usuario.

## Integracoes que exigem passo manual

### Google Drive

Valido apenas quando `gdrive_enable: true`.

Na primeira maquina:

```bash
rclone config
```

Crie um remote chamado `gdrive` e depois rerode o playbook.

O projeto prepara:

- `~/GoogleDrive`
- bind para `~/docs`
- `~/GoogleDrive/ssh` para backup manual de chaves SSH

### Syncthing

Valido apenas quando `syncthing_enable: true`.

Depois do provisionamento:

```bash
sudo systemctl status "syncthing@$(id -un)"
xdg-open http://127.0.0.1:8384
```

O playbook habilita o servico e prepara as pastas, mas o pareamento entre maquinas e a configuracao de folders continuam manuais.

### Docker

Depois do primeiro provisionamento, faca logout/login para aplicar o grupo `docker` ao usuario.

### OpenClaw

Valido apenas quando `openclaw_enable: true`.

O playbook prepara:

- instalacao do `openclaw` via `npm` no ambiente Node gerenciado por NVM
- launcher em `~/.local/bin/openclaw`
- workspace dedicado em `~/.openclaw/workspace`
- configuracao local segura em `~/.openclaw/openclaw.json`
- servico systemd `openclaw-gateway`

Depois do provisionamento:

```bash
systemctl status openclaw-gateway --no-pager
openclaw dashboard
```

Na primeira abertura do dashboard:

- autenticar o provedor/modelo desejado com `openclaw onboard` ou `openclaw configure`
- revisar o workspace em `~/.openclaw/workspace`
- opcionalmente conectar canais externos apenas se voce realmente quiser um assistente sempre acessivel fora da UI local

### Contexto de IA e vibe coding

Valido quando `ai_assistant_enable: true`.

O playbook prepara:

- `~/.ai-assistant/AGENTS.md` com regras gerais para agentes
- `~/.ai-assistant/WORKFLOWS.md` com comandos recorrentes
- `~/.ai-assistant/SAFETY.md` com guardrails
- `~/.ai-assistant/PROJECTS.md` com inventario dos repositorios conhecidos
- `~/.ai-assistant/SKILLS.md` com indice das skills locais
- `~/.ai-assistant/skills` com skills versionadas deste projeto
- `~/.codex/skills` com copia das skills para descoberta do Codex

O repositorio tambem possui:

- [AGENTS.md](/home/fernando/projects/vib/workstation-provision/AGENTS.md)
- [docs/ARCHITECTURE.md](/home/fernando/projects/vib/workstation-provision/docs/ARCHITECTURE.md)
- `.codex/skills/` com workflows especializados
- `.github/copilot-instructions.md` para GitHub Copilot
- `.cursor/rules/` para Cursor
- `.editorconfig` para convencoes de edicao

Opcionalmente, o role pode semear nos projetos clonados:

- `AGENTS.md`
- `.github/copilot-instructions.md`
- `.cursor/rules/ai-readiness.mdc`

Por seguranca, isso fica desabilitado por padrao. Para habilitar globalmente:

```yaml
ai_assistant_project_pack_enable: true
```

Ou por repositorio:

```yaml
projects_repos:
  - name: platform-api
    path: "vib/platform-api"
    url: "git@github.com:Vibxtech/platform-api.git"
    stack: "java-maven"
    ai_profile: "backend-service"
    validate: "mvn test"
    ai_ready: true
```

Os arquivos sao criados com `force: false` por padrao para nao sobrescrever
orientacoes ja existentes nos repositorios.

## Dotfiles

O role de shell instala `chezmoi` e pode aplicar dotfiles de duas formas:

- repositorio remoto via `chezmoi_repo`
- fonte local neste projeto, em `./chezmoi`

No estado atual, o conteudo versionado em `chezmoi/` e aplicado automaticamente e composto apenas por aliases Bash.

## Personalizacao

Pontos mais comuns de personalizacao:

- versoes de linguagens em [group_vars/all.yml](/home/fernando/projects/vib/workstation-provision/group_vars/all.yml)
- habilitacao do OpenClaw em [group_vars/all.yml](/home/fernando/projects/vib/workstation-provision/group_vars/all.yml) e [roles/openclaw/defaults/main.yml](/home/fernando/projects/vib/workstation-provision/roles/openclaw/defaults/main.yml)
- habilitacao do contexto de IA em [group_vars/all.yml](/home/fernando/projects/vib/workstation-provision/group_vars/all.yml) e [roles/ai_assistant/defaults/main.yml](/home/fernando/projects/vib/workstation-provision/roles/ai_assistant/defaults/main.yml)
- apps desktop em [roles/desktop_apps/defaults/main.yml](/home/fernando/projects/vib/workstation-provision/roles/desktop_apps/defaults/main.yml)
- apps removidos ao final em [roles/cleanup_apps/defaults/main.yml](/home/fernando/projects/vib/workstation-provision/roles/cleanup_apps/defaults/main.yml)
- configuracao de shell em [roles/shell/tasks/main.yml](/home/fernando/projects/vib/workstation-provision/roles/shell/tasks/main.yml) e [roles/shell_env/tasks/main.yml](/home/fernando/projects/vib/workstation-provision/roles/shell_env/tasks/main.yml)
- baseline do assistente em [roles/openclaw/templates/AGENTS.md.j2](/home/fernando/projects/vib/workstation-provision/roles/openclaw/templates/AGENTS.md.j2) e [roles/openclaw/templates/openclaw.json.j2](/home/fernando/projects/vib/workstation-provision/roles/openclaw/templates/openclaw.json.j2)
- projetos clonados em [group_vars/all.yml](/home/fernando/projects/vib/workstation-provision/group_vars/all.yml)

Exemplo de ajuste de perfil:

```yaml
syncthing_enable: false
gdrive_enable: false
openclaw_enable: false
projects_enable: false
projects_repos: []
ai_assistant_enable: true
ai_assistant_install_codex_skills: true
ai_assistant_project_pack_enable: false
```

Exemplo de ajuste de versoes:

```yaml
python_version: "3.12.2"
node_version: "lts/*"
java_version: "24-open"
```

## Validacao

Atalhos disponiveis no [Makefile](/home/fernando/projects/vib/workstation-provision/Makefile):

```bash
make install
make install PROFILE=collaborator.yml
make check
make syntax
make lint
make lint-yaml
make lint-ansible
make dry-run PROFILE=personal.yml
make verify
```

Observacao:
- `make check` exige `ansible-playbook` instalado no ambiente
- `make lint` exige `pre-commit` instalado
- `make dry-run` executa `ansible-playbook --check` e pode exigir sudo

## Troubleshooting rapido

### Ver status do onboarding gerado

```bash
cat ~/WORKSTATION_ONBOARDING.md
```

### Verificar Docker

```bash
docker version
docker compose version
```

### Verificar OpenClaw

```bash
systemctl status openclaw-gateway --no-pager
openclaw --version
openclaw dashboard
```

### Verificar contexto de IA

```bash
ls ~/.ai-assistant
cat ~/.ai-assistant/WORKFLOWS.md
find ~/.ai-assistant/skills -maxdepth 2 -name SKILL.md
```

### Verificar apps desktop

```bash
flatpak list
command -v code
command -v intellij-idea-ultimate
```

### Verificar shell

```bash
ls ~/.bashrc.d
type __fzf_history
```

### Ver logs detalhados do provisionamento

```bash
./bootstrap.sh 2>&1 | tee bootstrap.log
ansible-playbook -i inventory.ini site.yml --ask-become-pass -vv 2>&1 | tee ansible-run.log
```

## Estrutura do projeto

- [site.yml](/home/fernando/projects/vib/workstation-provision/site.yml): playbook principal
- [group_vars/all.yml](/home/fernando/projects/vib/workstation-provision/group_vars/all.yml): variaveis globais
- `profiles/`: overrides por tipo de maquina
- `roles/common`: base do sistema
- `roles/cinnamon`: ajustes de desktop Cinnamon
- `roles/shell_env` e `roles/shell`: shell, prompt e integracoes
- `roles/dev_tools`: linguagens e tooling de desenvolvimento
- `roles/devops`: Docker e ferramentas de infraestrutura
- `roles/openclaw`: assistente pessoal local com gateway, workspace e servico
- `roles/ai_assistant`: contexto, skills e AI readiness pack opcional
- `roles/desktop_apps`: catalogo de apps e fallbacks
- `roles/projects`: clonagem de repositorios
- `roles/syncthing`: sincronizacao entre maquinas
- `roles/gdrive`: montagem do Google Drive com `rclone`
- `roles/cleanup_apps`: remocao de apps preinstalados e limpeza final
- `roles/onboarding`: gera `~/WORKSTATION_ONBOARDING.md`

## Observacoes finais

- O perfil [personal.yml](/home/fernando/projects/vib/workstation-provision/profiles/personal.yml) concentra a lista pessoal de `projects_repos`.
- Alguns componentes dependem de rede externa e repositorios de terceiros.
- O provisionamento tenta limpar legados comuns do proprio projeto, mas uma maquina muito alterada pode exigir ajuste pontual.
