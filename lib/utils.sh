#!/bin/bash
comand_exists() { command -v "$1" &>/dev/null; }

is_root() { [ "$EUID" -eq 0 ]; }

confirm() {
  if [[ "${AUTO_CONFIRM:-false}" == "true" ]]; then
    log_info "$1 [auto-confirmado]"
    return 0
  fi
  read -rp "$1 [s/N]: " resposta
  [[ "$resposta" =~ ^[sS]$ ]]
}