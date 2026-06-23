#!/bin/bash
_backup_db() {
  [ -z "${DB_TIPO:-}" ] && return 0

  local timestamp="$1" dump_file

  case "$DB_TIPO" in
    postgres)
      dump_file="$BACKUP_ORIGEM/db_dump_${timestamp}.dump"
      log_debug "Dump PostgreSQL: $DB_NOME -> $dump_file"
      # -Fc: formato custom do pg_dump, compactado e restaurável com pg_restore.
      # Credenciais via ~/.pgpass ou PGPASSWORD — nunca hardcodar aqui.
      pg_dump -Fc -h "$DB_HOST" -U "$DB_USUARIO" "$DB_NOME" -f "$dump_file" || {
        log_erro "Falha no dump PostgreSQL de $DB_NOME"
        return 1
      }
      ;;
    mysql)
      dump_file="$BACKUP_ORIGEM/db_dump_${timestamp}.sql.gz"
      log_debug "Dump MySQL: $DB_NOME -> $dump_file"
      # --single-transaction garante consistência sem locks em tabelas InnoDB.
      # Credenciais via ~/.my.cnf ([client] password=...) ou MYSQL_PWD — nunca hardcodar aqui.
      # Subshell com pipefail para detectar falha do mysqldump mesmo que gzip termine com sucesso.
      ( set -o pipefail; mysqldump --single-transaction -h "$DB_HOST" -u "$DB_USUARIO" "$DB_NOME" \
        | gzip > "$dump_file" ) || {
        log_erro "Falha no dump MySQL de $DB_NOME"
        return 1
      }
      ;;
    *)
      log_erro "DB_TIPO invalido: '$DB_TIPO' (valores aceitos: postgres, mysql)"
      return 1
      ;;
  esac

  log_info "Dump de banco criado: $dump_file"
}

backup_run() {
  validate_directory "$BACKUP_ORIGEM"
  validate_directory "$BACKUP_DESTINO"
  validate_positive_integer "BACKUP_MARGEM_MB" "$BACKUP_MARGEM_MB"

  local tamanho_origem mb_necessarios
  tamanho_origem=$(du -sm "$BACKUP_ORIGEM" | awk '{print $1}')
  mb_necessarios=$(( tamanho_origem + BACKUP_MARGEM_MB ))
  validate_disk_space "$BACKUP_DESTINO" "$mb_necessarios"

  local timestamp
  timestamp=$(date '+%Y%m%d_%H%M%S')

  _backup_db "$timestamp"

  local destino="$BACKUP_DESTINO/backup_${timestamp}.tar.gz"

  log_debug "Criando backup: $BACKUP_ORIGEM -> $destino"

  # 'tar -czf' empacota arquivos e diretórios, incluindo dumps de banco gerados por _backup_db.
  tar -czf "$destino" -C "$(dirname "$BACKUP_ORIGEM")" "$(basename "$BACKUP_ORIGEM")"

  # Em produção, validar a integridade do arquivo gerado antes de considerar o backup bem-sucedido.
  tar -tzf "$destino" > /dev/null || { log_erro "Backup corrompido: $destino"; return 1; }
  log_info "Backup criado: $destino"

  # Em produção, implementar retenção para evitar acúmulo indefinido de arquivos.
  # Exemplo: remover backups com mais de 7 dias:
  #   find "$BACKUP_DESTINO" -name "backup_*.tar.gz" -mtime +7 -delete
}
