---
name: workstation-verify
description: Verify a provisioned Linux Mint workstation created by this repository. Use when Codex needs to validate installed tools, optional services, generated onboarding output, Docker, Kubernetes, language runtimes, OpenClaw, or AI assistant context.
---

# Workstation Verify

Use esta skill para validar uma maquina apos provisionamento.

## Checklist Rapido

```bash
make check
cat ~/WORKSTATION_ONBOARDING.md
docker version
docker compose version
flatpak remotes
apt-cache policy snapd
```

## Servicos Opcionais

```bash
systemctl status openclaw-gateway --no-pager
systemctl status "syncthing@$(id -un)" --no-pager
systemctl status rclone-gdrive --no-pager
```

## Ferramentas

```bash
java -version
node --version
uv --version
kubectl version --client
helm version
kind version
k9s version
flutter doctor -v
```

## Resultado Esperado

Reporte falhas por categoria: sistema, shell, linguagens, devops, desktop,
servicos opcionais e projetos clonados.
