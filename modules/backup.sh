#!/bin/bash
backup_run() {
  validate_directory "$BACKUP_ORIGEM"
  validate_directory "$BACKUP_DESTINO"

  local timestamp
  timestamp=$(date '+%Y%m%d_%H%M%S')
  local destino="$BACKUP_DESTINO/backup_${timestamp}.tar.gz"

  log_debug "Criando backup: $BACKUP_ORIGEM -> $destino"
  tar -czf "$destino" -C "$(dirname "$BACKUP_ORIGEM")" "$(basename "$BACKUP_ORIGEM")"
  log_info "Backup criado: $destino"
}
