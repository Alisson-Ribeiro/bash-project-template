#!/bin/bash
check_deps_run() {
  # Expandir esta lista com todas as ferramentas que os módulos reais do projeto usam.
  # Exemplos comuns em produção: pg_dump (PostgreSQL), mysqldump (MySQL),
  # aws (AWS CLI para S3), rsync (sincronização remota), jq (parsing JSON).
  # Em produção, considerar também verificar versões mínimas de ferramentas críticas
  # (ex: aws --version, pg_dump --version) para evitar incompatibilidades silenciosas.
  local deps=(curl tar jq)
  local faltando=()

  for dep in "${deps[@]}"; do
    if ! command_exists "$dep"; then
      faltando+=("$dep")
    else
      log_debug "Dependência OK: $dep"
    fi
  done

  if [ "${#faltando[@]}" -gt 0 ]; then
    log_erro "Dependências ausentes: ${faltando[*]}"
    return 1
  fi

  log_info "Todas as dependências satisfeitas"
}
