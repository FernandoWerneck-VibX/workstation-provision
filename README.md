# Fernando Workstation

Provisionamento de workstation para Linux Mint 22.x (Cinnamon) com Ansible.

Objetivo: pegar uma maquina nova e sair com sistema, shell, ferramentas de desenvolvimento, apps desktop e servicos opcionais prontos, com suporte a perfis pessoal e colaborador.

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
- `pay-respects`
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

Catalogo atual em [roles/desktop_apps/defaults/main.yml](/home/fernando/projects/vib/personal-workstation/roles/desktop_apps/defaults/main.yml):

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
- aplicacao de dotfiles via `chezmoi`
- clonagem automatica de projetos Git

## Perfis

Perfis disponiveis:

- [profiles/personal.yml](/home/fernando/projects/vib/personal-workstation/profiles/personal.yml): mantem Syncthing, Google Drive e clonagem de projetos ativos
- [profiles/collaborator.yml](/home/fernando/projects/vib/personal-workstation/profiles/collaborator.yml): desativa recursos pessoais

## Como executar

### 1. Clonar o repositorio

```bash
git clone <repo>
cd personal-workstation
```

### 2. Ajustar variaveis obrigatorias

Revise [group_vars/all.yml](/home/fernando/projects/vib/personal-workstation/group_vars/all.yml):

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

O inventario local esta em [inventory.ini](/home/fernando/projects/vib/personal-workstation/inventory.ini) e fixa o interpretador em `/usr/bin/python3` para nao depender de `pyenv` ou ferramentas do usuario.

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

## Dotfiles

O role de shell instala `chezmoi` e pode aplicar dotfiles de duas formas:

- repositorio remoto via `chezmoi_repo`
- fonte local neste projeto, em `./chezmoi`

No estado atual, o conteudo versionado em `chezmoi/` e aplicado automaticamente e composto apenas por aliases Bash.

## Personalizacao

Pontos mais comuns de personalizacao:

- versoes de linguagens em [group_vars/all.yml](/home/fernando/projects/vib/personal-workstation/group_vars/all.yml)
- apps desktop em [roles/desktop_apps/defaults/main.yml](/home/fernando/projects/vib/personal-workstation/roles/desktop_apps/defaults/main.yml)
- apps removidos ao final em [roles/cleanup_apps/defaults/main.yml](/home/fernando/projects/vib/personal-workstation/roles/cleanup_apps/defaults/main.yml)
- configuracao de shell em [roles/shell/tasks/main.yml](/home/fernando/projects/vib/personal-workstation/roles/shell/tasks/main.yml) e [roles/shell_env/tasks/main.yml](/home/fernando/projects/vib/personal-workstation/roles/shell_env/tasks/main.yml)
- projetos clonados em [group_vars/all.yml](/home/fernando/projects/vib/personal-workstation/group_vars/all.yml)

Exemplo de ajuste de perfil:

```yaml
syncthing_enable: false
gdrive_enable: false
projects_enable: false
projects_repos: []
```

Exemplo de ajuste de versoes:

```yaml
python_version: "3.12.2"
node_version: "lts/*"
java_version: "24-open"
```

## Validacao

Atalhos disponiveis no [Makefile](/home/fernando/projects/vib/personal-workstation/Makefile):

```bash
make install
make install PROFILE=collaborator.yml
make check
make lint
```

Observacao:
- `make check` exige `ansible-playbook` instalado no ambiente
- `make lint` exige `pre-commit` instalado

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

- [site.yml](/home/fernando/projects/vib/personal-workstation/site.yml): playbook principal
- [group_vars/all.yml](/home/fernando/projects/vib/personal-workstation/group_vars/all.yml): variaveis globais
- `profiles/`: overrides por tipo de maquina
- `roles/common`: base do sistema
- `roles/cinnamon`: ajustes de desktop Cinnamon
- `roles/shell_env` e `roles/shell`: shell, prompt e integracoes
- `roles/dev_tools`: linguagens e tooling de desenvolvimento
- `roles/devops`: Docker e ferramentas de infraestrutura
- `roles/desktop_apps`: catalogo de apps e fallbacks
- `roles/projects`: clonagem de repositorios
- `roles/syncthing`: sincronizacao entre maquinas
- `roles/gdrive`: montagem do Google Drive com `rclone`
- `roles/cleanup_apps`: remocao de apps preinstalados e limpeza final
- `roles/onboarding`: gera `~/WORKSTATION_ONBOARDING.md`

## Observacoes finais

- O perfil [personal.yml](/home/fernando/projects/vib/personal-workstation/profiles/personal.yml) concentra a lista pessoal de `projects_repos`.
- Alguns componentes dependem de rede externa e repositorios de terceiros.
- O provisionamento tenta limpar legados comuns do proprio projeto, mas uma maquina muito alterada pode exigir ajuste pontual.
