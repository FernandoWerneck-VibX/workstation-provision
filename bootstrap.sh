#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
  echo "Execute este script com usuario comum (nao root)."
  exit 1
fi

PROFILE_DIR="profiles"
SELECTED_PROFILE="${1:-}"
PROFILE_ARG=()

resolve_profile() {
  local profile_name="$1"
  if [ -z "$profile_name" ] || [ "$profile_name" = "default" ] || [ "$profile_name" = "none" ]; then
    PROFILE_ARG=()
    return
  fi

  local profile_path="$PROFILE_DIR/$profile_name"
  if [ -f "$profile_path" ]; then
    PROFILE_ARG=(-e "@$profile_path")
    return
  fi

  echo "Perfil invalido: $profile_name"
  echo "Perfis disponiveis:"
  find "$PROFILE_DIR" -maxdepth 1 -type f -name "*.yml" -printf " - %f\n" | sort
  exit 1
}

select_profile_interactive() {
  local options=("default (sem perfil)")
  local files=()
  local file

  while IFS= read -r file; do
    files+=("$file")
    options+=("$file")
  done < <(find "$PROFILE_DIR" -maxdepth 1 -type f -name "*.yml" -printf "%f\n" | sort)

  echo "Selecione o perfil de provisionamento:"
  PS3="Opcao: "
  select choice in "${options[@]}"; do
    if [ -z "${choice:-}" ]; then
      echo "Opcao invalida."
      continue
    fi

    if [ "$choice" = "default (sem perfil)" ]; then
      PROFILE_ARG=()
      return
    fi

    PROFILE_ARG=(-e "@$PROFILE_DIR/$choice")
    return
  done
}

if [ -n "$SELECTED_PROFILE" ]; then
  resolve_profile "$SELECTED_PROFILE"
elif [ -d "$PROFILE_DIR" ] && [ -t 0 ]; then
  select_profile_interactive
else
  PROFILE_ARG=()
fi

sudo rm -f \
  /etc/apt/sources.list.d/fallback-com-visualstudio-code.list \
  /etc/apt/sources.list.d/vscode.list \
  /etc/apt/sources.list.d/vscode.sources
sudo apt update && sudo apt install -y ansible git
ansible-playbook -i inventory.ini site.yml --ask-become-pass "${PROFILE_ARG[@]}"
