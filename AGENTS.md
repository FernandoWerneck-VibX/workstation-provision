# Workstation Provision

Este repositorio provisiona uma workstation Linux Mint 22.x com Ansible.
Trate-o como automacao de sistema operacional: mudancas pequenas podem ter
efeito amplo na maquina do usuario.

## Comandos

Use estes comandos antes de concluir alteracoes:

```bash
make check
make lint
```

Comandos menores disponiveis:

```bash
make syntax
make lint-yaml
make lint-ansible
make dry-run PROFILE=personal.yml
```

`make dry-run` usa `ansible-playbook --check` e pode exigir sudo.

## Regras de Edicao

- Prefira padroes ja existentes nas roles.
- Mantenha variaveis em `defaults/main.yml` quando forem configuraveis.
- Use `group_vars/all.yml` para defaults globais que cruzam roles.
- Evite hardcode de usuario, home ou caminhos pessoais.
- Use `dev_user`, `dev_home`, `projects_dir` e variaveis equivalentes.
- Nao introduza secrets, tokens ou chaves privadas no repositorio.
- Nao remova recursos existentes sem necessidade clara.

## Ansible

- Preserve idempotencia sempre que possivel.
- Para comandos shell, use `creates`, `changed_when` ou verificacoes previas.
- Tarefas que rodam como usuario devem usar `become_user: "{{ dev_user }}"`.
- Tarefas de sistema podem usar o `become: yes` do playbook principal.
- Handlers devem ser usados para reiniciar servicos quando templates mudarem.

## Estrutura

- `site.yml`: ordem principal das roles.
- `group_vars/all.yml`: variaveis globais.
- `profiles/`: overrides por tipo de maquina.
- `roles/common`: base do sistema.
- `roles/dev_tools`: linguagens e ferramentas de desenvolvimento.
- `roles/devops`: Docker, Kubernetes e ferramentas de infra.
- `roles/openclaw`: instalacao do OpenClaw.
- `roles/ai_assistant`: contexto e readiness pack para agentes de IA.
- `roles/projects`: clonagem e preparo opcional dos repositorios.
- `roles/onboarding`: checklist final gerado na maquina.

## Fluxo Seguro

1. Leia a role afetada antes de editar.
2. Faca a menor mudanca que resolve o pedido.
3. Atualize defaults, README ou onboarding se a mudanca for configuravel.
4. Rode `make check`.
5. Rode `make lint` quando as ferramentas estiverem instaladas.

