#!/usr/bin/env bats

setup() {
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  LOG_ARQUIVO=$(mktemp); export LOG_ARQUIVO
  export VERBOSE=false
  source "$DIR/config/config.sh"
  source "$DIR/lib/log.sh"
  source "$DIR/lib/utils.sh"
  source "$DIR/modules/check_deps.sh"
  # Deps base (curl, tar, jq) sempre presentes; ferramentas DB ausentes por padrão.
  # Testes que precisam de pg_dump ou mysqldump sobrescrevem command_exists localmente.
  command_exists() {
    case "$1" in
      curl|tar|jq) return 0 ;;
      *) return 1 ;;
    esac
  }
  export -f command_exists
}

teardown() {
  rm -f "$LOG_ARQUIVO"
}

@test "check_deps_run sem DB_TIPO nao exige pg_dump nem mysqldump" {
  export DB_TIPO=""
  run check_deps_run
  [ "$status" -eq 0 ]
  [[ "$output" != *"pg_dump"* ]]
  [[ "$output" != *"mysqldump"* ]]
}

@test "check_deps_run com DB_TIPO=postgres falha quando pg_dump ausente" {
  export DB_TIPO="postgres"
  run check_deps_run
  [ "$status" -eq 1 ]
  [[ "$output" == *"pg_dump"* ]]
}

@test "check_deps_run com DB_TIPO=postgres passa quando pg_dump disponivel" {
  export DB_TIPO="postgres"
  command_exists() {
    case "$1" in
      curl|tar|jq|pg_dump) return 0 ;;
      *) return 1 ;;
    esac
  }
  export -f command_exists
  run check_deps_run
  [ "$status" -eq 0 ]
}

@test "check_deps_run com DB_TIPO=mysql falha quando mysqldump ausente" {
  export DB_TIPO="mysql"
  run check_deps_run
  [ "$status" -eq 1 ]
  [[ "$output" == *"mysqldump"* ]]
}

@test "check_deps_run com DB_TIPO=mysql passa quando mysqldump disponivel" {
  export DB_TIPO="mysql"
  command_exists() {
    case "$1" in
      curl|tar|jq|mysqldump) return 0 ;;
      *) return 1 ;;
    esac
  }
  export -f command_exists
  run check_deps_run
  [ "$status" -eq 0 ]
}
