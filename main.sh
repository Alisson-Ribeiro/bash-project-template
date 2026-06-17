#!/bin/bash
# set -euo pipefail: aborta em qualquer erro, rejeita variáveis não definidas e
# propaga falhas em pipes. Não remover em produção — protege contra erros silenciosos.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$DIR/config/config.sh"
source "$DIR/lib/log.sh"
source "$DIR/lib/utils.sh"
source "$DIR/lib/validation.sh"
source "$DIR/lib/runner.sh"

# Em produção, o cleanup pode ser estendido para enviar um alerta de falha
# (ex: chamar notify_run com mensagem de erro) antes de encerrar.
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

# Em produção automatizada (cron, CI/CD), definir AUTO_CONFIRM=true no ambiente.
# O 'read' dentro de confirm() trava indefinidamente sem terminal interativo.
if confirm "Continuar?"; then
  log_info "Confirmado pelo usuário"
else
  log_aviso "Operação cancelada pelo usuário"
  exit 0
fi

# A ordem do pipeline importa: check_deps deve sempre ser o primeiro módulo
# para garantir que o ambiente está apto antes de qualquer operação com efeito colateral.
# Para adicionar um módulo: crie modules/<nome>.sh, adicione à whitelist em runner.sh
# e inclua o nome aqui na posição correta.
PIPELINE=(check_deps backup notify)

for modulo in "${PIPELINE[@]}"; do
  run_module "$modulo"
done

trap - EXIT
log_info "Pipeline concluído com sucesso"