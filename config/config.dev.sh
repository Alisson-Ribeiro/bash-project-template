#!/bin/bash
# shellcheck disable=SC2034
# Configurações de desenvolvimento. Nunca usar estes valores em produção.

# VERBOSE=true é adequado para dev — exibe mensagens DEBUG no terminal.
# Em produção manter false para não poluir logs com detalhes internos.
VERBOSE=true

# Paths em /tmp são convenientes para dev mas inadequados para produção:
# perdem dados em reboot, sem controle de permissão e sem garantia de espaço.
LOG_ARQUIVO="/tmp/myapp-dev.log"
BACKUP_ORIGEM="/tmp/myapp_origem"
BACKUP_DESTINO="/tmp/myapp_backup"
