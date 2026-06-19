#!/usr/bin/env bats

setup() {
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  export LOG_ARQUIVO=$(mktemp)
  export VERBOSE=false
  export APP_NOME="TestApp"
  export AMBIENTE="test"
  source "$DIR/config/config.sh"
  source "$DIR/lib/log.sh"
  source "$DIR/modules/notify.sh"

  jq() {
    while [[ $# -gt 0 ]]; do
      [[ "$1" == "--arg" && "$2" == "text" ]] && { echo "$3"; return 0; }
      shift
    done
  }
  export -f jq

  curl() {
    while [[ $# -gt 0 ]]; do
      [[ "$1" == "-d" ]] && { echo "$2"; return 0; }
      shift
    done
  }
  export -f curl
}

teardown() {
  rm -f "$LOG_ARQUIVO"
}

@test "notify_run sem SLACK_WEBHOOK_URL retorna 0 e loga aviso" {
  export SLACK_WEBHOOK_URL=""
  run notify_run
  [ "$status" -eq 0 ]
  [[ "$output" == *"SLACK_WEBHOOK_URL nao definida"* ]]
}

@test "notify_run de falha sem SLACK_WEBHOOK_URL retorna 0" {
  export SLACK_WEBHOOK_URL=""
  run notify_run "falha" "Script abortado na linha 10"
  [ "$status" -eq 0 ]
  [[ "$output" == *"SLACK_WEBHOOK_URL nao definida"* ]]
}

@test "notify_run sem args envia mensagem de sucesso" {
  export SLACK_WEBHOOK_URL="https://fake.webhook"
  run notify_run
  [ "$status" -eq 0 ]
  [[ "$output" == *"Pipeline concluido com sucesso"* ]]
}

@test "notify_run de falha envia mensagem com FALHA e motivo" {
  export SLACK_WEBHOOK_URL="https://fake.webhook"
  run notify_run "falha" "Script abortado na linha 10"
  [ "$status" -eq 0 ]
  [[ "$output" == *"FALHA"* ]]
  [[ "$output" == *"Script abortado na linha 10"* ]]
}

@test "notify_run retorna 0 mesmo quando curl falha" {
  export SLACK_WEBHOOK_URL="https://fake.webhook"
  curl() { return 1; }
  export -f curl
  run notify_run "falha" "erro"
  [ "$status" -eq 0 ]
}
