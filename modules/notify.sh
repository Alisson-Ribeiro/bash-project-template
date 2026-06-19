#!/bin/bash
notify_run() {
  # Em produção, nunca carregar SLACK_WEBHOOK_URL de arquivo de config commitado.
  # Opções seguras: injetar via CI/CD secrets, carregar de secret manager em tempo
  # de execução (ex: aws secretsmanager get-secret-value) ou ler de arquivo protegido
  # fora do repositório (permissão 600, fora do BACKUP_ORIGEM).
  local status="${1:-sucesso}" motivo="${2:-}"

  if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
    log_aviso "SLACK_WEBHOOK_URL nao definida — notificacao ignorada"
    return 0
  fi

  local base mensagem
  base="[$APP_NOME] $(date '+%Y-%m-%d %H:%M:%S') (ambiente: $AMBIENTE, host: $(hostname))"
  if [ "$status" = "falha" ]; then
    mensagem="$base — FALHA: $motivo"
  else
    # Em produção, enriquecer a mensagem com contexto útil para diagnóstico:
    # duração do pipeline e resultado de cada módulo.
    mensagem="$base — Pipeline concluido com sucesso"
  fi
  log_debug "Enviando notificacao para webhook"

  # Em produção, para notificações críticas implementar retentativa com backoff:
  #   for tentativa in 1 2 3; do
  #     curl -s ... && break || sleep $((tentativa * 5))
  #   done
  local payload
  # shellcheck disable=SC2016  # $text é variável jq, não bash
  payload=$(jq -nc --arg text "$mensagem" '{"text": $text}')
  curl -s -X POST "$SLACK_WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "$payload" || {
      log_aviso "Falha ao enviar notificacao — nao critico"
      return 0
    }

  log_info "Notificacao enviada"
}
