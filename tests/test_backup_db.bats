#!/usr/bin/env bats

setup() {
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  LOG_ARQUIVO=$(mktemp); export LOG_ARQUIVO
  export VERBOSE=false
  BACKUP_ORIGEM=$(mktemp -d); export BACKUP_ORIGEM
  source "$DIR/config/config.sh"
  source "$DIR/lib/log.sh"
  source "$DIR/modules/backup.sh"
}

teardown() {
  rm -f "$LOG_ARQUIVO"
  rm -rf "$BACKUP_ORIGEM"
}

@test "_backup_db retorna 0 e nao faz nada quando DB_TIPO e vazio" {
  export DB_TIPO=""
  pg_dump()    { return 1; }; export -f pg_dump
  mysqldump()  { return 1; }; export -f mysqldump
  run _backup_db "20260622_120000"
  [ "$status" -eq 0 ]
  [ -z "$(ls "$BACKUP_ORIGEM")" ]
}

@test "_backup_db cria dump postgres com extensao .dump" {
  export DB_TIPO="postgres" DB_NOME="mydb" DB_HOST="localhost" DB_USUARIO="postgres"
  pg_dump() { local f_next=false; for a in "$@"; do $f_next && { echo "DUMP_DATA" > "$a"; return 0; }; [[ "$a" == "-f" ]] && f_next=true; done; }; export -f pg_dump
  run _backup_db "20260622_120000"
  [ "$status" -eq 0 ]
  [ -f "$BACKUP_ORIGEM/db_dump_20260622_120000.dump" ]
}

@test "_backup_db cria dump mysql com extensao .sql.gz" {
  export DB_TIPO="mysql" DB_NOME="mydb" DB_HOST="localhost" DB_USUARIO="root"
  mysqldump() { echo "SQL_DATA"; }; export -f mysqldump
  run _backup_db "20260622_120000"
  [ "$status" -eq 0 ]
  [ -f "$BACKUP_ORIGEM/db_dump_20260622_120000.sql.gz" ]
}

@test "_backup_db retorna 1 quando pg_dump falha" {
  export DB_TIPO="postgres" DB_NOME="mydb" DB_HOST="localhost" DB_USUARIO="postgres"
  pg_dump() { return 1; }; export -f pg_dump
  run _backup_db "20260622_120000"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Falha no dump PostgreSQL"* ]]
}

@test "_backup_db retorna 1 quando mysqldump falha" {
  export DB_TIPO="mysql" DB_NOME="mydb" DB_HOST="localhost" DB_USUARIO="root"
  mysqldump() { return 1; }; export -f mysqldump
  run _backup_db "20260622_120000"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Falha no dump MySQL"* ]]
}

@test "_backup_db retorna 1 para DB_TIPO invalido" {
  export DB_TIPO="oracle"
  run _backup_db "20260622_120000"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DB_TIPO invalido"* ]]
  [[ "$output" == *"postgres, mysql"* ]]
}
