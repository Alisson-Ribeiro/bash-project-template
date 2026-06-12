#!/bin/bash
_VERDE='\033[0;32m'
_VERMELHO='\033[0;31m'
_AMARELO='\033[0;33m'
_CIANO='\033[0;36m'
_RESET='\033[0m'

_log() {
  local cor="$1" prefixo="$2"
  shift 2
  local msg
  msg="[$prefixo] $(date '+%H:%M:%S') - $*"
  echo -e "${cor}${msg}${_RESET}" | tee -a "$LOG_ARQUIVO"
}

log_info()  { _log "$_VERDE"    "INFO " "$@"; }
log_erro()  { _log "$_VERMELHO" "ERRO " "$@" >&2; }
log_aviso() { _log "$_AMARELO"  "AVISO" "$@"; }
log_debug() { [[ "${VERBOSE:-false}" == "true" ]] && _log "$_CIANO" "DEBUG" "$@" || true; }