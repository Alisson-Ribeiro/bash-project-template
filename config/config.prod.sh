#!/bin/bash
# shellcheck disable=SC2034
VERBOSE=false
LOG_ARQUIVO="/var/log/myapp.log"
BACKUP_ORIGEM="${BACKUP_ORIGEM:-/var/data}"
BACKUP_DESTINO="${BACKUP_DESTINO:-/mnt/backup}"
