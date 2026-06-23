#!/usr/bin/env bats

setup() {
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  LOG_ARQUIVO=$(mktemp); export LOG_ARQUIVO
  export VERBOSE=false
  BACKUP_ORIGEM=$(mktemp -d); export BACKUP_ORIGEM
  BACKUP_DESTINO=$(mktemp -d); export BACKUP_DESTINO
  export BACKUP_MARGEM_MB=1
  export DB_TIPO=""
  echo "conteudo" > "$BACKUP_ORIGEM/arquivo.txt"
  source "$DIR/config/config.sh"
  source "$DIR/lib/log.sh"
  source "$DIR/lib/validation.sh"
  source "$DIR/modules/backup.sh"
}

teardown() {
  rm -f "$LOG_ARQUIVO"
  rm -rf "$BACKUP_ORIGEM" "$BACKUP_DESTINO"
}

@test "backup_run cria tar.gz em BACKUP_DESTINO no caminho feliz" {
  run backup_run
  [ "$status" -eq 0 ]
  [ -n "$(ls "$BACKUP_DESTINO"/backup_*.tar.gz 2>/dev/null)" ]
  [[ "$output" == *"Backup criado"* ]]
}

@test "backup_run retorna 1 quando BACKUP_ORIGEM nao existe" {
  export BACKUP_ORIGEM="/tmp/nao_existe_backup_origem_xyz"
  run backup_run
  [ "$status" -eq 1 ]
  [[ "$output" == *"Diretório não encontrado"* ]]
}

@test "backup_run retorna 1 quando BACKUP_DESTINO nao existe" {
  export BACKUP_DESTINO="/tmp/nao_existe_backup_destino_xyz"
  run backup_run
  [ "$status" -eq 1 ]
  [[ "$output" == *"Diretório não encontrado"* ]]
}

@test "backup_run retorna 1 quando BACKUP_MARGEM_MB e invalido" {
  export BACKUP_MARGEM_MB="abc"
  run backup_run
  [ "$status" -eq 1 ]
  [[ "$output" == *"inteiro positivo"* ]]
}

@test "backup_run retorna 1 quando _backup_db falha e nao cria tar.gz" {
  _backup_db() { return 1; }
  export -f _backup_db
  run backup_run
  [ "$status" -eq 1 ]
  [ -z "$(ls "$BACKUP_DESTINO"/backup_*.tar.gz 2>/dev/null)" ]
}
