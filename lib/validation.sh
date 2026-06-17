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