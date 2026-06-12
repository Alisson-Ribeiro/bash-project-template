#!/bin/bash
# Loads configuration and utility functions, then runs the main logic of the application
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # Ensures scripts work regardless of current directory
source "$DIR/config/config.sh"
source "$DIR/lib/log.sh"
source "$DIR/lib/utils.sh"
source "$DIR/lib/validation.sh"

# --- Main ---
log_info "Initializing $APP_NOME v$APP_VERSAO"

if ! comand_exists curl; then
  log_erro "curl is not installed"
  exit 1
fi

if confirm "Continue?"; then
  log_info "Confirmed by user"
else
  log_aviso "Operation cancelled by user"
  exit 0
fi