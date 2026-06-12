#!/bin/bash
check_deps_run() {
  local deps=(curl tar)
  local faltando=()

  for dep in "${deps[@]}"; do
    if ! comand_exists "$dep"; then
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
