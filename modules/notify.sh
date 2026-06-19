#!/bin/bash
notify_run() {
  # Em produção, nunca carregar credenciais de arquivo de config commitado.
  # Opções seguras: injetar via CI/CD secrets, carregar de secret manager em tempo
  # de execução (ex: aws secretsmanager get-secret-value) ou ler de arquivo protegido
  # fora do repositório (permissão 600, fora do BACKUP_ORIGEM).
  local status="${1:-sucesso}" motivo="${2:-}"

  local base mensagem
  base="[$APP_NOME] $(date '+%Y-%m-%d %H:%M:%S') (ambiente: $AMBIENTE, host: $(hostname))"
  if [ "$status" = "falha" ]; then
    mensagem="$base — FALHA: $motivo"
  else
    # Em produção, enriquecer a mensagem com contexto útil para diagnóstico:
    # duração do pipeline e resultado de cada módulo.
    mensagem="$base — Pipeline concluido com sucesso"
  fi

  if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
    log_debug "Enviando notificacao para webhook"
    # Em produção, para notificações críticas implementar retentativa com backoff:
    #   for tentativa in 1 2 3; do
    #     curl -s ... && break || sleep $((tentativa * 5))
    #   done
    local payload
    # shellcheck disable=SC2016  # $text é variável jq, não bash
    payload=$(jq -nc --arg text "$mensagem" '{"text": $text}')
    if curl -s -X POST "$SLACK_WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -d "$payload"; then
      log_info "Notificacao Slack enviada"
    else
      log_aviso "Falha ao enviar notificacao Slack — nao critico"
    fi
  else
    log_aviso "SLACK_WEBHOOK_URL nao definida — notificacao Slack ignorada"
  fi

  if [ -n "${EMAIL_DESTINATARIO:-}" ]; then
    # Requer MTA local (Postfix, Sendmail, Exim) com entrega funcional.
    # Em cloud, verificar se o provider bloqueia porta 25 e configurar relay SMTP se necessário.
    if ! command -v mail &>/dev/null; then
      log_aviso "Comando 'mail' nao encontrado — notificacao por e-mail ignorada"
    else
      local assunto
      assunto="[$APP_NOME] $status em $(date '+%Y-%m-%d %H:%M:%S') ($AMBIENTE)"
      if echo "$mensagem" | mail -s "$assunto" "$EMAIL_DESTINATARIO"; then
        log_info "E-mail enviado para $EMAIL_DESTINATARIO"
      else
        log_aviso "Falha ao enviar e-mail — nao critico"
      fi
    fi
  fi
}
