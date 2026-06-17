#!/usr/bin/env bats

setup() {
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export LOG_ARQUIVO=$(mktemp)
  export VERBOSE=false
  export AUTO_CONFIRM=false
  source "$DIR/config/config.sh"
  source "$DIR/lib/log.sh"
  source "$DIR/lib/utils.sh"
}

teardown() {
  rm -f "$LOG_ARQUIVO"
}

@test "command_exists retorna 0 para comando existente" {
  run command_exists bash
  [ "$status" -eq 0 ]
}

@test "command_exists retorna 1 para comando inexistente" {
  run command_exists comando_que_nao_existe_xyz
  [ "$status" -eq 1 ]
}

@test "is_root retorna 1 quando não é root" {
  run is_root
  [ "$status" -eq 1 ]
}

@test "confirm retorna 0 com AUTO_CONFIRM=true" {
  export AUTO_CONFIRM=true
  run confirm "Continuar?"
  [ "$status" -eq 0 ]
}
