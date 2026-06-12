#!/bin/bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DIR/config/config.sh"
source "$DIR/lib/log.sh"
source "$DIR/lib/utils.sh"
source "$DIR/lib/validation.sh"
source "$DIR/lib/runner.sh"

cleanup() {
  log_aviso "Script encerrado (linha $1)"
}
trap 'cleanup $LINENO' ERR EXIT

usage() {
  echo "Uso: $0 [-e ambiente] [-v] [-h]"
  echo "  -e  Ambiente: dev | prod (padrão: dev)"
  echo "  -v  Modo verbose"
  echo "  -h  Exibe esta ajuda"
  exit 0
}

while getopts "e:vh" opt; do
  case $opt in
    e) AMBIENTE="$OPTARG" ;;
    v) VERBOSE=true ;;
    h) usage ;;
    *) usage ;;
  esac
done

ENV_CONFIG="$DIR/config/config.${AMBIENTE}.sh"
if [ -f "$ENV_CONFIG" ]; then
  # shellcheck source=/dev/null
  source "$ENV_CONFIG"
fi

# --- Main ---
log_info "Inicializando $APP_NOME v$APP_VERSAO (ambiente: $AMBIENTE)"
log_debug "Verbose ativado"

if confirm "Continuar?"; then
  log_info "Confirmado pelo usuário"
else
  log_aviso "Operação cancelada pelo usuário"
  exit 0
fi

PIPELINE=(check_deps backup notify)

for modulo in "${PIPELINE[@]}"; do
  run_module "$modulo"
done

trap - EXIT
log_info "Pipeline concluído com sucesso"