#!/usr/bin/env bats

setup() {
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export LOG_ARQUIVO=$(mktemp)
  export VERBOSE=false
  source "$DIR/config/config.sh"
  source "$DIR/lib/log.sh"
  source "$DIR/lib/validation.sh"
}

teardown() {
  rm -f "$LOG_ARQUIVO"
}

@test "validate_file retorna 0 para arquivo existente" {
  run validate_file "$DIR/tests/fixtures/arquivo_valido.txt"
  [ "$status" -eq 0 ]
}

@test "validate_file retorna 1 para arquivo inexistente" {
  run validate_file "/tmp/arquivo_que_nao_existe_xyz_123"
  [ "$status" -eq 1 ]
}

@test "validate_directory retorna 0 para diretório existente" {
  run validate_directory "$DIR/lib"
  [ "$status" -eq 0 ]
}

@test "validate_directory retorna 1 para diretório inexistente" {
  run validate_directory "/tmp/diretorio_que_nao_existe_xyz_123"
  [ "$status" -eq 1 ]
}

@test "validate_positive_integer retorna 0 para inteiro positivo valido" {
  run validate_positive_integer "BACKUP_MARGEM_MB" "100"
  [ "$status" -eq 0 ]
}

@test "validate_positive_integer retorna 0 para valor minimo (1)" {
  run validate_positive_integer "BACKUP_MARGEM_MB" "1"
  [ "$status" -eq 0 ]
}

@test "validate_positive_integer retorna 1 para string" {
  run validate_positive_integer "BACKUP_MARGEM_MB" "abc"
  [ "$status" -eq 1 ]
  [[ "$output" == *"deve ser um inteiro positivo"* ]]
}

@test "validate_positive_integer retorna 1 para decimal" {
  run validate_positive_integer "BACKUP_MARGEM_MB" "10.5"
  [ "$status" -eq 1 ]
  [[ "$output" == *"deve ser um inteiro positivo"* ]]
}

@test "validate_positive_integer retorna 1 para valor negativo" {
  run validate_positive_integer "BACKUP_MARGEM_MB" "-5"
  [ "$status" -eq 1 ]
  [[ "$output" == *"deve ser um inteiro positivo"* ]]
}

@test "validate_positive_integer retorna 1 para zero" {
  run validate_positive_integer "BACKUP_MARGEM_MB" "0"
  [ "$status" -eq 1 ]
  [[ "$output" == *"deve ser um inteiro positivo"* ]]
}

@test "validate_positive_integer retorna 1 para valor vazio" {
  run validate_positive_integer "BACKUP_MARGEM_MB" ""
  [ "$status" -eq 1 ]
  [[ "$output" == *"deve ser um inteiro positivo"* ]]
}
