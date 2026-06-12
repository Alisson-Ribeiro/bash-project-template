#!/bin/bash
comand_exists() { command -v "$1" &>/dev/null; }

is_root() { [ "$EUID" -eq 0 ]; }

confirm() {
  read -rp "$1 [s/N]: " resposta
  [[ "$resposta" =~ ^[sS]$ ]]
}