#!/usr/bin/env bats

setup() {
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export LOG_ARQUIVO=$(mktemp)
  export VERBOSE=false
  source "$DIR/config/config.sh"
  source "$DIR/lib/log.sh"
}

teardown() {
  rm -f "$LOG_ARQUIVO"
}

@test "log_info escreve prefixo INFO" {
  run log_info "mensagem de teste"
  [[ "$output" == *"INFO"* ]]
}

@test "log_info inclui a mensagem" {
  run log_info "mensagem de teste"
  [[ "$output" == *"mensagem de teste"* ]]
}

@test "log_info grava no arquivo de log" {
  log_info "gravando no arquivo"
  grep -q "gravando no arquivo" "$LOG_ARQUIVO"
}

@test "log_erro escreve prefixo ERRO" {
  run log_erro "algo deu errado"
  [[ "$output" == *"ERRO"* ]]
}

@test "log_aviso escreve prefixo AVISO" {
  run log_aviso "atenção"
  [[ "$output" == *"AVISO"* ]]
}

@test "log_debug não imprime sem VERBOSE=true" {
  export VERBOSE=false
  run log_debug "mensagem debug"
  [[ "$output" == "" ]]
}

@test "log_debug imprime com VERBOSE=true" {
  export VERBOSE=true
  run log_debug "mensagem debug"
  [[ "$output" == *"DEBUG"* ]]
}
