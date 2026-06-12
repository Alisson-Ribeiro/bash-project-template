#!/bin/bash
log_info()  { echo "[INFO]  $(date '+%H:%M:%S') — $*" | tee -a "$LOG_ARQUIVO"; }
log_erro()  { echo "[ERRO]  $(date '+%H:%M:%S') — $*" | tee -a "$LOG_ARQUIVO" >&2; }
log_aviso() { echo "[AVISO] $(date '+%H:%M:%S') — $*" | tee -a "$LOG_ARQUIVO"; }