#!/bin/bash
# shellcheck disable=SC2034
# Configurações de produção. Valores sensíveis (senhas, tokens, URLs de webhook)
# nunca devem estar neste arquivo — use variáveis de ambiente injetadas pelo sistema de deploy.

VERBOSE=false

# Garantir que /var/log/myapp.log existe antes do primeiro uso:
#   sudo mkdir -p /var/log && sudo touch /var/log/myapp.log
#   sudo chown <usuario-do-script> /var/log/myapp.log
# Configurar rotação em /etc/logrotate.d/myapp para evitar crescimento indefinido.
LOG_ARQUIVO="/var/log/myapp.log"

# Apontar para os dados reais: diretório da aplicação, dump de banco (pg_dump, mysqldump), etc.
# Substitua /var/data pelo caminho correto do seu ambiente.
BACKUP_ORIGEM="${BACKUP_ORIGEM:-/var/data}"

# Deve ser um volume persistente e separado do servidor de aplicação:
# NFS montado, disco externo, bucket S3 via s3fs/goofys, ou similar.
# Nunca usar o mesmo disco do sistema operacional — uma falha de disco elimina app e backup.
BACKUP_DESTINO="${BACKUP_DESTINO:-/mnt/backup}"
