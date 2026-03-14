# 🧰 Fernando Workstation — Provisionamento Profissional para Linux Mint (Cinnamon) com Ansible

Este repositório contém um conjunto completo de **playbooks Ansible**, **roles modulares** e **scripts de automação**
para configurar rapidamente uma estação de trabalho Linux Mint totalmente preparada para desenvolvimento moderno.

Compatível com **Linux Mint 22.3 (Cinnamon)**, baseado em Ubuntu 24.04 LTS.
O projeto mantém compatibilidade com a família Mint 22.x e aplica ajustes de desktop via `gsettings` (Cinnamon/GNOME) quando disponível.

A proposta principal é simples:

> **Ligar uma máquina nova → rodar o bootstrap → sair com tudo configurado, idêntico em todas as máquinas.**

---

# 🚀 Principais Recursos

- **Sistema Operacional Otimizado**
  - Atualizações automatizadas
  - Remoção de apps desnecessários na etapa final do provisionamento
  - Snap desativado (`snapd` removido e bloqueado)
  - Flatpak/Flathub como padrão
  - Codecs multimídia instalados (`mint-meta-codecs`)
  - Sysctl e ZRAM otimizados (`vm.swappiness=5`)
  - `fstrim.timer` e `irqbalance` habilitados
  - `tlp` habilitado apenas em notebooks
  - `tlp-pd` instalado quando disponível no repositório apt
  - `power-profiles-daemon` removido apenas quando o notebook passa a usar TLP
  - Extensão `gTile` instalada a partir do Cinnamon Spices

- **Ambiente de Desenvolvimento Completo**
  - Java (SDKMAN, Maven, Gradle)
  - Node (NVM, Yarn, PNPM, Vue CLI, Vite)
  - Python (Pyenv)
  - Flutter SDK

- **DevOps e Kubernetes**
  - Docker + Compose
  - kubectl
  - k9s
  - helm
  - kind

- **Shell Produtivo (Bash)**
  - fzf
  - ripgrep
  - bat
  - bash-git-prompt
  - ble.sh (autosuggestions + syntax highlighting)
  - pay-respects (correção/sugestão de comandos)
  - Git com autocompletion
  - Zsh não é configurado por padrão

- **Aplicativos Essenciais**
  - Chrome
  - Visual Studio Code
  - IntelliJ IDEA Ultimate
  - Sublime Text
  - Obsidian
  - Postman
  - Discord
  - Ferdium (multi-conta para mensageria)
  - Kazam (gravação de tela)
  - Snapshot/Cheese (webcam/foto/vídeo rápido)
  - SSH Pilot (GUI para múltiplas conexões SSH)
  - Spotify
  - Audiotube (YouTube Music)
  - Celluloid (vídeo)
  - gThumb (imagens)
  - Flatpak/Flathub como padrão (fallback .deb/apt/tarball)

- **Google Drive Integrado (Documentos)**
  - rclone + systemd service
  - bind automático para `~/docs`

- **Sincronização Entre Máquinas (Syncthing)**
  - serviço `syncthing@usuario` habilitado
  - pasta padrão sincronizável: `~/Downloads`
  - pareamento de dispositivos via UI: `http://127.0.0.1:8384`

- **Gerenciamento de Dotfiles**
  - Chezmoi integrado (aplica automaticamente via `chezmoi_repo` ou pasta local `./chezmoi`)

- **Clonagem Automática de Projetos**
  - Repositórios definidos em `group_vars/all.yml` são clonados em `~/projects`
  - Estrutura por subpasta suportada (ex.: `~/projects/vib/*` e `~/projects/personal/*`)

---

# 🧭 Como Usar

## 🔹 1. Baixe o repositório (ou clone no GitHub)

```bash
git clone git@github.com:FernandoWerneck-VibX/fernando-workstation.git
cd fernando-workstation
```

## 🔹 2. Ajustes obrigatórios antes da primeira execução

Edite o arquivo `group_vars/all.yml`:

- `git_user_name` e `git_user_email` (obrigatório preencher)
- `chezmoi_repo` (opcional, se quiser aplicar dotfiles de um repositório remoto)
- `projects_repos` (já vem com exemplos reais e clonagem automática habilitada)

`dev_user` e `dev_home` são resolvidos automaticamente a partir do usuário do SO que executa o `ansible-playbook`.

Se usar repositórios Git privados (`git@github.com:...`), garanta que sua chave SSH está configurada no GitHub antes de rodar o playbook.

Ajuste `inventory.ini` apenas se precisar de algo específico.
Por padrão, o projeto usa conexão local e detecta automaticamente o usuário do SO que executa o `ansible-playbook`.

```ini
[local]
localhost ansible_connection=local
```

## 🔹 3. Execute o bootstrap

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

O `bootstrap.sh` pergunta interativamente qual perfil usar (`default`, `personal.yml` ou `collaborator.yml`).
Se preferir sem prompt, passe o perfil por argumento:

```bash
./bootstrap.sh collaborator.yml
```

Execute como usuario comum (nao `root` e sem `sudo` no comando do playbook).
O provisionamento valida `dev_user` e interrompe se ele resolver para `root`.

O script irá:

1. Instalar Ansible
2. Instalar Git
3. Executar o playbook principal

Atualizações do sistema, upgrades e demais mudanças de estado ficam centralizadas no playbook, não no `bootstrap.sh`.

## 🔹 4. Use perfis por tipo de máquina (pessoal x colaborador)

Este projeto agora inclui perfis prontos em `profiles/`:

- `profiles/personal.yml` (mantém tudo ativo)
- `profiles/collaborator.yml` (desativa Google Drive, Syncthing e clonagem automática de projetos)

Exemplo para notebook de colaborador:

```bash
ansible-playbook -i inventory.ini site.yml --ask-become-pass -e @profiles/collaborator.yml
```

Exemplo para sua máquina pessoal:

```bash
ansible-playbook -i inventory.ini site.yml --ask-become-pass -e @profiles/personal.yml
```

---

# ⚙️ Primeira Execução com Google Drive

Use esta etapa apenas quando `gdrive_enable: true` (ex.: perfil `personal`).

A integração com o Google Drive usa **rclone**.

Na primeira máquina, execute:

```bash
rclone config
```

Siga os passos na tela e configure um remote chamado `gdrive`.

Depois, execute o playbook novamente:

```bash
ansible-playbook -i inventory.ini site.yml --ask-become-pass
```

Isso ativará:

- `~/GoogleDrive`
- Bind para `~/docs`  

Obs: o serviço só inicia se `~/.config/rclone/rclone.conf` existir.

---

# 🔄 Primeira Execução com Syncthing

Use esta etapa apenas quando `syncthing_enable: true` (ex.: perfil `personal`).

Após rodar o playbook, o serviço do Syncthing ficará ativo:

```bash
sudo systemctl status "syncthing@$(id -un)"
```

Abra a interface web local para parear os dispositivos:

```bash
xdg-open http://127.0.0.1:8384
```

Obs: o playbook prepara o serviço e as pastas, mas o pareamento de dispositivos e IDs de pasta é feito uma vez na UI.

---

# 🧾 Onboarding Automático

Ao final do playbook, é gerado um checklist com resumo do ambiente e próximos passos:

```bash
cat ~/WORKSTATION_ONBOARDING.md
```

O arquivo inclui:

- O que foi provisionado
- O que ainda precisa de configuração manual
- Comandos de validação rápida

## O que ainda é manual (resumo rápido)

- Configurar `rclone config` (Google Drive) na primeira máquina, se `gdrive_enable: true`
- Parear dispositivos/pastas no Syncthing (`http://127.0.0.1:8384`), se `syncthing_enable: true`
- Fazer logout/login para aplicar grupo `docker`
- Configurar contas dos apps (Chrome, Discord, Ferdium, Spotify etc.)
- Se usar Git privado: configurar chave SSH no provedor
- Para dotfiles automáticos: definir `chezmoi_repo` ou criar uma pasta local `./chezmoi` neste projeto

---

# 🛠 Personalização

Toda a personalização do ambiente fica em:

```
group_vars/all.yml
```

### Exemplos de configurações disponíveis:

```yaml
# Detectado automaticamente a partir do usuario que executa o ansible-playbook
dev_user: "{{ lookup('env', 'SUDO_USER') | default(lookup('env', 'USER'), true) }}"
dev_home: "/home/{{ dev_user }}"

git_user_name: "SEU_NOME"
git_user_email: "seu-email@exemplo.com"

java_version: "24-open"
node_version: "lts/*"
python_version: "3.12.2"
flutter_version: "latest"
flutter_channel: "stable"
kubectl_version: "latest"
helm_version: "latest"
k9s_version: "latest"
kind_version: "latest"
syncthing_enable: true
gdrive_enable: true
projects_enable: true
syncthing_folders:
  - "{{ dev_home }}/Downloads"
cinnamon_enable_gtile: true
common_tlp_notebook_only: true
common_enable_tlp_pd: true

chezmoi_repo: ""

projects_repos:
  - name: telegram-bot
    path: vib/telegram-bot
    url: https://github.com/Vibxtech/telegram-bot.git
  - name: workstation-monitor
    path: vib/workstation-monitor
    url: https://github.com/Vibxtech/workstation-monitor.git
  - name: market-analysis-data
    path: personal/market-analysis-data
    url: git@github.com:FernandoWerneck/market-analysis-data.git

flatpak_apps:
  - id: "com.jetbrains.IntelliJ-IDEA-Ultimate"
  - id: "md.obsidian.Obsidian"
  - id: "com.getpostman.Postman"
  - id: "org.ferdium.Ferdium"
  - id: "org.gnome.Snapshot"
  - id: "io.github.mfat.sshpilot"
  - id: "com.spotify.Client"
  - id: "org.kde.audiotube"
```

No estado atual do projeto:

- `chezmoi_repo` vem vazio por padrão, mas você pode aplicar dotfiles com:
  - repositório remoto (`chezmoi_repo`)
  - fonte local no projeto (`./chezmoi`)
- `projects_repos` já vem preenchido e os repositórios são clonados em `~/projects` mantendo subpastas (`vib/*` e `personal/*`)
- `gTile` é instalado a partir do repositório oficial `linuxmint/cinnamon-spices-extensions`
- `tlp` só é aplicado automaticamente quando a máquina é detectada como notebook
- `tlp-pd` é instalado apenas se existir nos repositórios apt disponíveis

Opcional: caso queira forçar outro release Ubuntu para o repositório Docker, defina:

```yaml
docker_apt_release: "noble"
```

Você pode customizar:

- Versões de linguagens
- Repositório de dotfiles
- Repositórios a serem clonados
- Nome do usuário
- Estrutura de pastas
- Apps a instalar nas roles
- Fallbacks por app (apt, deb ou tarball)

Opcional: para Postman via `.deb`, configure `postman_deb_url` e `postman_deb_package_name` em `group_vars/all.yml`.

Exemplo de fallback por app:

```yaml
flatpak_apps:
  - id: "com.getpostman.Postman"
    fallback:
      tarball: "https://dl.pstmn.io/download/latest/linux64"
      install_dir: "/opt"
      validate_path: "/opt/Postman/Postman"
```

---

# 🧪 Testes e Troubleshooting

## 🔹 Testar se o Google Drive montou corretamente

```bash
mount | grep GoogleDrive
```

## 🔹 Reiniciar o serviço do Google Drive

```bash
sudo systemctl restart rclone-gdrive
```

## 🔹 Testar Syncthing

```bash
sudo systemctl status "syncthing@$(id -un)"
```

## 🔹 Testar Docker

```bash
docker run hello-world
```

Se der erro de permissao, faça logout/login para aplicar o grupo `docker`.

## 🔹 Testar se os repositórios foram clonados

```bash
ls ~/projects
```

## 🔹 Testar configurações do Bash

```bash
echo $PROMPT_COMMAND
type _fzf_history
```

## 🔹 Ver logs de erros do Ansible

```bash
./bootstrap.sh 2>&1 | tee bootstrap.log
```

ou

```bash
ansible-playbook -i inventory.ini site.yml --ask-become-pass -vv 2>&1 | tee ansible-run.log
```

---

# 🎯 Motivação do Projeto

Este projeto nasceu da necessidade de:

- Eliminar horas de configuração manual após formatar uma máquina  
- Garantir que computadores diferentes tenham exatamente o **mesmo ambiente**  
- Acelerar o onboarding em novas máquinas ou ambientes de trabalho  
- Padronizar ferramentas, versões e comportamento do sistema  
- Aumentar produtividade e evitar discrepâncias entre setups pessoais/profissionais  
- Criar uma workstation robusta, moderna e confiável  

A configuração manual pode levar **3 a 5 horas** — aqui, tudo leva apenas **10 minutos**.

---

# 📄 Licença

**MIT License**

Você pode:

- Usar
- Modificar
- Adaptar
- Distribuir
- Incorporar em projetos pessoais ou corporativos

Tudo livremente.

```
Copyright 2025  
Permissão é concedida...
```
