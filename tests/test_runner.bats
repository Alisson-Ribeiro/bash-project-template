#!/usr/bin/env bats

setup() {
  DIR_REAL="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  LOG_ARQUIVO=$(mktemp); export LOG_ARQUIVO
  export VERBOSE=false
  TMPDIR_RUNNER=$(mktemp -d)
  mkdir -p "$TMPDIR_RUNNER/modules"
  echo 'fake_ok_run() { echo "modulo_ok"; }' > "$TMPDIR_RUNNER/modules/fake_ok.sh"
  source "$DIR_REAL/config/config.sh"
  source "$DIR_REAL/lib/log.sh"
  source "$DIR_REAL/lib/runner.sh"
  # shellcheck disable=SC2034  # usado por _modulo_permitido via referência indireta
  MODULOS_PERMITIDOS=(fake_ok fake_sem_arquivo)
  export DIR="$TMPDIR_RUNNER"
}

teardown() {
  rm -f "$LOG_ARQUIVO"
  rm -rf "$TMPDIR_RUNNER"
}

@test "_modulo_permitido retorna 0 para modulo na whitelist" {
  run _modulo_permitido "fake_ok"
  [ "$status" -eq 0 ]
}

@test "_modulo_permitido retorna 1 para modulo fora da whitelist" {
  run _modulo_permitido "backup"
  [ "$status" -eq 1 ]
}

@test "_modulo_permitido retorna 1 para path traversal" {
  run _modulo_permitido "../etc/passwd"
  [ "$status" -eq 1 ]
}

@test "_modulo_permitido retorna 1 para string vazia" {
  run _modulo_permitido ""
  [ "$status" -eq 1 ]
}

@test "run_module retorna 1 para modulo nao permitido" {
  run run_module "shell"
  [ "$status" -eq 1 ]
  [[ "$output" == *"não permitido"* ]]
}

@test "run_module retorna 1 quando arquivo do modulo nao existe" {
  run run_module "fake_sem_arquivo"
  [ "$status" -eq 1 ]
  [[ "$output" == *"não encontrado"* ]]
}

@test "run_module executa modulo permitido com arquivo valido" {
  run run_module "fake_ok"
  [ "$status" -eq 0 ]
  [[ "$output" == *"modulo_ok"* ]]
}
