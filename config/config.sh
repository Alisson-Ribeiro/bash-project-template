#!/bin/bash
# shellcheck disable=SC2034
APP_NOME="MyApp"
APP_VERSAO="1.0.0"
LOG_ARQUIVO="/tmp/myapp.log"
AMBIENTE="${AMBIENTE:-dev}"
VERBOSE="${VERBOSE:-false}"
AUTO_CONFIRM="${AUTO_CONFIRM:-false}"
BACKUP_ORIGEM="${BACKUP_ORIGEM:-/tmp/myapp_origem}"
BACKUP_DESTINO="${BACKUP_DESTINO:-/tmp/myapp_backup}"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"