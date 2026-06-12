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
