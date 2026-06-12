#!/bin/bash
notify_run() {
  if [ -z "${SLACK_WEBHOOK_URL:-}" ]; then
    log_aviso "SLACK_WEBHOOK_URL não definida — notificação ignorada"
    return 0
  fi

  local mensagem
  mensagem="[$APP_NOME] Pipeline concluido em $(date '+%Y-%m-%d %H:%M:%S') (ambiente: $AMBIENTE)"
  log_debug "Enviando notificação para webhook"

  curl -s -X POST "$SLACK_WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "{\"text\": \"$mensagem\"}" || {
      log_aviso "Falha ao enviar notificação — não crítico"
      return 0
    }

  log_info "Notificação enviada"
}
