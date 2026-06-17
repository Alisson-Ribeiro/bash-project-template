#!/bin/bash
# Whitelist de módulos permitidos — barreira de segurança contra path injection.
# Sempre que um novo módulo for criado em modules/, adicionar o nome aqui.
# Não remover esta verificação em produção: sem ela, qualquer valor em PIPELINE
# poderia causar 'source' de um arquivo arbitrário no sistema.
MODULOS_PERMITIDOS=(check_deps backup notify)

_modulo_permitido() {
  local alvo="$1"
  local m
  for m in "${MODULOS_PERMITIDOS[@]}"; do
    [[ "$m" == "$alvo" ]] && return 0
  done
  return 1
}

run_module() {
  local modulo="$1"

  if ! _modulo_permitido "$modulo"; then
    log_erro "Módulo não permitido: '$modulo'"
    return 1
  fi

  local caminho="$DIR/modules/${modulo}.sh"
  if [ ! -f "$caminho" ]; then
    log_erro "Arquivo do módulo não encontrado: $caminho"
    return 1
  fi

  log_info ">> Iniciando módulo: $modulo"
  # shellcheck source=/dev/null
  source "$caminho"
  "${modulo}_run"
  log_info ">> Módulo concluído: $modulo"
}
