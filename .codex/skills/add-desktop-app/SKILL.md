---
name: add-desktop-app
description: Add or update desktop applications in the workstation-provision Ansible catalog. Use when Codex needs to change roles/desktop_apps, choose Flatpak versus apt or tarball fallback, update app metadata, or document desktop app provisioning.
---

# Add Desktop App

Use esta skill ao adicionar ou ajustar aplicativos desktop.

## Workflow

1. Leia `roles/desktop_apps/defaults/main.yml`.
2. Confira os tipos ja suportados em
   `roles/desktop_apps/tasks/install_single_app.yml`.
3. Prefira Flatpak quando o app existir no Flathub.
4. Use repositorio apt oficial quando o app precisar de integracao nativa.
5. Para tarball, defina checksum quando a fonte publicar um valor confiavel.
6. Atualize README e o checklist de onboarding se o app for relevante.
7. Rode `make check` e `make lint-ansible`.

## Campos Esperados

Mantenha o formato do catalogo atual. Novos campos devem ser usados apenas se
`install_single_app.yml` souber interpreta-los.

## Riscos

- Apps desktop podem depender de rede, chave GPG, arquitetura e sandbox.
- Evite URLs nao oficiais.
- Evite adicionar apps pessoais ao perfil de colaborador.
