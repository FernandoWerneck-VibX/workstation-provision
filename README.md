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
- AWS CLI v2
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
- Sublime Text 4
- Postman
- Discord
- Spotify
- Ferdium
- Telegram Desktop (3 instancias isoladas)
- Snapshot
- SSH Pilot
- Audiotube
- Kazam2 (gravacao de tela, instalado do git em `/opt/kazam2`)
- Celluloid
- gThumb

Observacoes:
- o projeto prioriza Flatpak para apps desktop, com fallback nativo quando necessario
- VS Code usa repositorio oficial da Microsoft
- IntelliJ IDEA Ultimate usa download oficial da JetBrains

#### Instancias do Telegram Desktop

O cliente oficial e nativo (Qt/C++, GPLv3) e aceita 3 contas por instancia no
plano gratuito. Para ir alem, `desktop_apps_telegram_instances` gera uma
instancia isolada por entrada usando as flags oficiais `-many` (desliga o lock
de instancia unica) e `-workdir` (diretorio de dados proprio) — sem nenhuma
feature paga:

- cada instancia tem sessao, contas e configuracao independentes
- cada instancia ainda aceita 3 contas, ou seja 3 instancias = 9 contas
- cada uma ganha um lancador proprio em `~/.local/share/applications`
- a instancia `principal` usa o workdir padrao, o mesmo do lancador exportado
  pelo Flatpak, para nao duplicar dados

Ajuste a lista em [roles/desktop_apps/defaults/main.yml](roles/desktop_apps/defaults/main.yml)
para adicionar, renomear ou remover instancias.

### Integracoes opcionais

- Syncthing
- Google Drive via `rclone`
- OpenClaw como assistente pessoal local
- AI assistant context independente de ferramenta (`~/.ai-assistant`)
- Google Calendar desklet no perfil pessoal
- Cinnamon Dynamic Wallpaper no perfil pessoal
- aplicacao de dotfiles via `chezmoi`
- clonagem automatica de projetos Git

## Atualizacao automatica

Objetivo: nada instalado por este projeto deve depender de voce rodar o
bootstrap de novo, nem de clicar em "atualizar". Sao tres camadas, todas
sem interacao:

| Camada | Cobre | Mecanismo | Frequencia |
| --- | --- | --- | --- |
| Flatpak | apps desktop (Chrome, Firefox, Telegram, Ferdium, Discord, Spotify, Postman, Sublime...) | `flatpak-update.timer` | diaria + 3min apos o boot |
| apt | pacotes do sistema e repos de terceiros (VS Code, Docker, GitHub CLI, Syncthing, rclone, pay-respects...) | `unattended-upgrades` + `apt-daily-upgrade.timer` | diaria |
| playbook | o resto: binarios em `/usr/local/bin` (kubectl, helm, k9s, kind, atuin), tarballs em `/opt` (IntelliJ, Flutter), AWS CLI, NVM/npm globais, uv e suas ferramentas, ble.sh, bash-git-prompt, chezmoi, Maven/Gradle | `workstation-selfupdate.timer` | semanal (`Sun 03:30`) |

A terceira camada e o `roles/auto_updates`: como todas as roles resolvem
"latest" em tempo de execucao, **rodar o playbook ja e o mecanismo de
atualizacao** — o timer so passou a chama-lo sozinho. Ele roda
`ansible-playbook` como root, com `flock` contra execucoes sobrepostas,
`Persistent=true` (recupera a execucao perdida se a maquina estava desligada) e
log em `/var/log/workstation-selfupdate.log` com rotacao semanal.

Pontos de configuracao em [roles/auto_updates/defaults/main.yml](roles/auto_updates/defaults/main.yml):

- `auto_updates_enable`: desliga as duas camadas de uma vez
- `auto_updates_apt_origins`: origens liberadas no `unattended-upgrades`
  (padrao `origin=*`, senao os repos de terceiros ficariam parados)
- `auto_updates_apt_automatic_reboot`: `false` — a maquina nunca reinicia sozinha
- `auto_updates_selfupdate_oncalendar`: quando reaplicar o playbook
- `auto_updates_selfupdate_profile`: perfil a reaplicar, definido em cada
  arquivo de `profiles/` (precisa casar com o perfil usado no bootstrap)
- `auto_updates_selfupdate_git_pull`: `false` — nao mexe em trabalho local
  nao commitado; ligue se quiser que a maquina puxe o repo antes de aplicar
- `auto_updates_selfupdate_skip_tags`: roles a pular na execucao automatica

O que continua **pinado de proposito** (atualizar e decisao, nao rotina):
`java_version`, `python_version`, `node_version`, `nvm_version` — troque a
variavel quando quiser subir de versao.

Status e execucao manual:

```bash
systemctl list-timers 'flatpak-update*' 'workstation-selfupdate*' 'apt-daily*'
systemctl status workstation-selfupdate --no-pager
sudo tail -f /var/log/workstation-selfupdate.log
sudo systemctl start workstation-selfupdate   # forca a atualizacao agora
```

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

### Verificar GitHub CLI e Docker

```bash
gh --version
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
ls ~/.local/share/applications/telegram-*.desktop
```

### Verificar as atualizacoes automaticas

```bash
systemctl list-timers 'flatpak-update*' 'workstation-selfupdate*' 'apt-daily*'
sudo unattended-upgrade --dry-run --debug | tail -20
sudo tail -20 /var/log/workstation-selfupdate.log
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
- `roles/auto_updates`: `unattended-upgrades` e timer de reaplicacao do playbook
- `roles/cleanup_apps`: remocao de apps preinstalados e limpeza final
- `roles/onboarding`: gera `~/WORKSTATION_ONBOARDING.md`

## Observacoes finais

- O perfil [personal.yml](/home/fernando/projects/vib/workstation-provision/profiles/personal.yml) concentra a lista pessoal de `projects_repos`.
- Alguns componentes dependem de rede externa e repositorios de terceiros.
- O provisionamento tenta limpar legados comuns do proprio projeto, mas uma maquina muito alterada pode exigir ajuste pontual.
