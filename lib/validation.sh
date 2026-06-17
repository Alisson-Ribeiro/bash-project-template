#!/bin/bash
# Funções de validação prontas para produção — sem mudanças necessárias na estrutura.
# Boas práticas de uso: chamar validate_file/validate_directory no início de cada
# módulo, antes de qualquer operação de leitura, escrita ou deleção, para garantir
# falha rápida com mensagem de erro clara em vez de comportamento imprevisível.

validate_file() {
  [ -f "$1" ] || { log_erro "Arquivo não encontrado: $1"; return 1; }
}

validate_directory() {
  [ -d "$1" ] || { log_erro "Diretório não encontrado: $1"; return 1; }
}

validate_disk_space() {
  local diretorio="$1" mb_necessarios="$2"
  local mb_livres
  mb_livres=$(df -m "$diretorio" | awk 'NR==2{print $4}')
  if [ "$mb_livres" -lt "$mb_necessarios" ]; then
    log_erro "Espaco insuficiente em $diretorio: ${mb_livres}MB livres, ${mb_necessarios}MB necessarios"
    return 1
  fi
  log_debug "Espaco em disco OK: ${mb_livres}MB livres em $diretorio (minimo: ${mb_necessarios}MB)"
}