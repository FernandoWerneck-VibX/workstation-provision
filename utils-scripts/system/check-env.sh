#!/bin/bash
java_version="$(java -version 2>&1 | head -n 1)"
node_version="$(node -v 2>/dev/null || echo "N/A")"
python_version="$(python3 --version 2>/dev/null || python --version 2>/dev/null || echo "N/A")"
bat_version="$(bat --version 2>/dev/null || batcat --version 2>/dev/null || echo "N/A")"
docker_version="$(docker --version 2>/dev/null || echo "N/A")"
gh_version="$(gh --version 2>/dev/null | head -n 1 || echo "N/A")"
aws_cli_version="$(aws --version 2>/dev/null || echo "N/A")"
k8s_version="$(kubectl version --client -o yaml 2>/dev/null | awk '/gitVersion:/ {print $2; exit}')"
helm_version="$(helm version --short 2>/dev/null || echo "N/A")"
k9s_version="$(k9s version --short 2>/dev/null | head -n 1)"
kind_version="$(kind version 2>/dev/null || echo "N/A")"
flutter_version="$(flutter --version 2>/dev/null | head -n 1)"

timer_state() {
  local unit="$1"
  local state
  state="$(systemctl is-enabled "$unit" 2>/dev/null || true)"
  case "$state" in
    enabled) echo "habilitado" ;;
    ""|not-found) echo "nao instalado" ;;
    *) echo "$state" ;;
  esac
}

flatpak_timer="$(timer_state flatpak-update.timer)"
selfupdate_timer="$(timer_state workstation-selfupdate.timer)"
if [ "$(dpkg-query -W -f='${db:Status-Status}' unattended-upgrades 2>/dev/null || true)" = "installed" ]; then
  apt_timer="$(timer_state apt-daily-upgrade.timer)"
else
  apt_timer="nao instalado"
fi

echo "Java: ${java_version:-N/A}"
echo "Node: ${node_version:-N/A}"
echo "Python: ${python_version:-N/A}"
echo "Bat: ${bat_version:-N/A}"
echo "Docker: ${docker_version:-N/A}"
echo "GitHub CLI: ${gh_version:-N/A}"
echo "AWS CLI: ${aws_cli_version:-N/A}"
echo "K8s: ${k8s_version:-N/A}"
echo "Helm: ${helm_version:-N/A}"
echo "K9s: ${k9s_version:-N/A}"
echo "Kind: ${kind_version:-N/A}"
echo "Flutter: ${flutter_version:-N/A}"
echo "Auto-update Flatpak: ${flatpak_timer}"
echo "Auto-update apt (unattended-upgrades): ${apt_timer}"
echo "Auto-update playbook (self-update): ${selfupdate_timer}"
