#!/bin/bash
backup_run() {
  validate_directory "$BACKUP_ORIGEM"
  validate_directory "$BACKUP_DESTINO"

  # Em produção, verificar espaço disponível antes de iniciar o backup para evitar
  # arquivos corrompidos por falta de disco:
  #   local espaco_livre; espaco_livre=$(df -m "$BACKUP_DESTINO" | awk 'NR==2{print $4}')
  #   [ "$espaco_livre" -gt 500 ] || { log_erro "Espaço insuficiente em $BACKUP_DESTINO"; return 1; }

  local timestamp
  timestamp=$(date '+%Y%m%d_%H%M%S')
  local destino="$BACKUP_DESTINO/backup_${timestamp}.tar.gz"

  log_debug "Criando backup: $BACKUP_ORIGEM -> $destino"

  # 'tar -czf' é adequado para arquivos e diretórios comuns.
  # Para banco de dados, substituir pelo dump nativo:
  #   PostgreSQL: pg_dump -Fc "$DB_NAME" -f "$destino"
  #   MySQL:      mysqldump "$DB_NAME" | gzip > "$destino"
  tar -czf "$destino" -C "$(dirname "$BACKUP_ORIGEM")" "$(basename "$BACKUP_ORIGEM")"

  # Em produção, validar a integridade do arquivo gerado antes de considerar o backup bem-sucedido.
  tar -tzf "$destino" > /dev/null || { log_erro "Backup corrompido: $destino"; return 1; }
  log_info "Backup criado: $destino"

  # Em produção, implementar retenção para evitar acúmulo indefinido de arquivos.
  # Exemplo: remover backups com mais de 7 dias:
  #   find "$BACKUP_DESTINO" -name "backup_*.tar.gz" -mtime +7 -delete
}
