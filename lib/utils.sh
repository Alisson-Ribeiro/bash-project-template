#!/bin/bash
command_exists() { command -v "$1" &>/dev/null; }

# Em produção, avaliar se o script realmente precisa de root.
# Rodar como root amplia o raio de impacto de qualquer bug ou comprometimento.
# Prefira criar um usuário dedicado com permissões mínimas necessárias.
is_root() { [ "$EUID" -eq 0 ]; }

confirm() {
  # Em produção automatizada (cron, CI/CD), definir AUTO_CONFIRM=true no ambiente.
  # Sem isso, o 'read' abaixo trava o script indefinidamente por falta de terminal.
  if [[ "${AUTO_CONFIRM:-false}" == "true" ]]; then
    log_info "$1 [auto-confirmado]"
    return 0
  fi
  read -rp "$1 [s/N]: " resposta
  [[ "$resposta" =~ ^[sS]$ ]]
}