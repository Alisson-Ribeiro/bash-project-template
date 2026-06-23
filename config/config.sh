#!/bin/bash
# shellcheck disable=SC2034
# Defaults globais do template. Em produção, os valores abaixo devem ser revisados.
# Variáveis sensíveis (webhooks, credenciais) nunca devem ser definidas aqui —
# injetar via secret manager (AWS Secrets Manager, HashiCorp Vault) ou CI/CD secrets.

# Substitua pelo nome e versão reais do seu projeto.
APP_NOME="MyApp"
APP_VERSAO="1.0.0"

# Em produção, usar /var/log/<app>/app.log.
# Certifique-se de que o diretório existe e o usuário que executa o script tem permissão de escrita.
# Configure logrotate para evitar crescimento indefinido do arquivo.
LOG_ARQUIVO="/tmp/myapp.log"

AMBIENTE="${AMBIENTE:-dev}"
VERBOSE="${VERBOSE:-false}"

# Em pipelines de CI/CD ou cron, sempre definir AUTO_CONFIRM=true no ambiente de execução.
# O comando 'read' trava indefinidamente em ambientes sem terminal interativo.
AUTO_CONFIRM="${AUTO_CONFIRM:-false}"

# Substitua pelos caminhos reais do seu projeto.
# BACKUP_ORIGEM: diretório da aplicação, dump do banco, arquivos de configuração, etc.
# BACKUP_DESTINO: preferencialmente um volume externo, NFS ou bucket S3 montado (s3fs/goofys).
# Nunca usar /tmp em produção — dados são perdidos em reboot e não há controle de permissão.
BACKUP_ORIGEM="${BACKUP_ORIGEM:-/tmp/myapp_origem}"
BACKUP_DESTINO="${BACKUP_DESTINO:-/tmp/myapp_backup}"
# Margem mínima de espaço livre exigida no destino além do tamanho da origem (em MB).
# Aumentar em produção para garantir espaço residual no volume após o backup.
BACKUP_MARGEM_MB="${BACKUP_MARGEM_MB:-100}"
# Backups com mais de N dias são removidos automaticamente após cada execução bem-sucedida.
# Definir como 0 para desabilitar a retenção.
BACKUP_RETENCAO_DIAS="${BACKUP_RETENCAO_DIAS:-7}"

# DB_TIPO: "postgres", "mysql" ou vazio (sem backup de banco).
# DB_NOME, DB_HOST, DB_USUARIO: injetar via ambiente em produção.
# Credenciais NUNCA devem estar neste arquivo:
#   PostgreSQL: usar ~/.pgpass ou PGPASSWORD no ambiente de execução.
#   MySQL:      usar ~/.my.cnf ([client] password=...) ou MYSQL_PWD no ambiente.
DB_TIPO="${DB_TIPO:-}"
DB_NOME="${DB_NOME:-}"
DB_HOST="${DB_HOST:-localhost}"
DB_USUARIO="${DB_USUARIO:-}"

# Não defina o valor aqui. Injete SLACK_WEBHOOK_URL como variável de ambiente protegida
# no sistema de CI/CD ou carregue de um secret manager em tempo de execução.
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
# Não defina o valor aqui. Injete EMAIL_DESTINATARIO como variável de ambiente protegida.
# Pré-requisito: o servidor precisa de um MTA local funcional (Postfix, Sendmail, Exim).
# Em ambientes cloud (EC2, GCE, Azure VM) a porta 25 geralmente está bloqueada pelo provider —
# configure um relay SMTP (ex: AWS SES, SendGrid) no MTA antes de usar este canal.
# Em containers Docker, o comando 'mail' frequentemente não está disponível — o script
# detecta a ausência automaticamente e ignora o envio sem abortar.
EMAIL_DESTINATARIO="${EMAIL_DESTINATARIO:-}"