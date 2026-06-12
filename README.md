# MyApp

![CI](https://github.com/seu-usuario/myapp/actions/workflows/ci.yml/badge.svg)

Template production-grade para automação com scripts Bash. Oferece estrutura modular, logging colorido com timestamps, pipeline de execução configurável, testes automatizados e integração contínua pronta para uso.

---

## Para que serve

Ponto de partida para scripts de automação que precisam de mais do que um arquivo `.sh` avulso:

- Pipelines de backup automatizado
- Automação de deploy em servidores Linux
- Scripts de operações (ops) executados em CI/CD
- Qualquer processo que envolva sequência de etapas, verificação de dependências e notificações

---

## Estrutura do projeto

```
.
├── main.sh                    # Ponto de entrada — orquestra o pipeline
├── config/
│   ├── config.sh              # Defaults globais e variáveis de ambiente
│   ├── config.dev.sh          # Overrides para desenvolvimento
│   └── config.prod.sh         # Overrides para produção
├── lib/
│   ├── log.sh                 # Logging colorido com níveis e timestamp
│   ├── utils.sh               # Utilitários gerais (comand_exists, confirm, is_root)
│   ├── validation.sh          # Validação de arquivos e diretórios
│   └── runner.sh              # Orquestrador de módulos com whitelist de segurança
├── modules/
│   ├── check_deps.sh          # Verifica dependências do sistema (curl, tar)
│   ├── backup.sh              # Cria backup comprimido com timestamp
│   └── notify.sh              # Envia notificação via webhook (ex: Slack)
├── tests/
│   ├── test_utils.bats        # Testes de utils.sh
│   ├── test_validation.bats   # Testes de validation.sh
│   ├── test_log.bats          # Testes de log.sh
│   └── fixtures/
│       └── arquivo_valido.txt # Fixture estática para testes de validação
└── .github/
    └── workflows/
        └── ci.yml             # Pipeline de CI: lint (shellcheck) + testes (bats)
```

---

## Pontos fortes

**Robustez**
O script principal roda com `set -euo pipefail`: aborta em qualquer erro, rejeita variáveis não definidas e propaga falhas em pipes. Um `trap` captura erros inesperados e registra a linha exata onde ocorreram.

**Modularidade**
Cada módulo do pipeline é um arquivo independente em `modules/` que expõe uma função `<nome>_run`. Adicionar ou remover um módulo é uma linha no array `PIPELINE` de `main.sh`. As bibliotecas em `lib/` são reutilizáveis em outros scripts do mesmo projeto.

**Segurança**
O runner valida o nome de cada módulo contra uma whitelist antes de fazer `source`, prevenindo path injection. Segredos (webhook URLs, credenciais) nunca ficam hardcoded — são sempre lidos de variáveis de ambiente.

**Testabilidade**
Suite de testes com bats-core cobrindo log, validação e utilitários. Cada teste usa `setup`/`teardown` com arquivos temporários (`mktemp`) para garantir isolamento total.

**CI pronto**
O workflow do GitHub Actions executa shellcheck e bats em todo push e pull request, sem configuração adicional.

**Suporte a múltiplos ambientes**
Configurações separadas para `dev` e `prod`. O ambiente é selecionado via flag `-e` e pode sobrescrever qualquer variável do `config.sh` base.

**Modo não-interativo**
A variável `AUTO_CONFIRM=true` desabilita prompts de confirmação, tornando o script seguro para uso em pipelines de CI/CD onde não há terminal interativo.

---

## Limitações

- **Não roda nativamente no Windows.** Requer Bash 4+ em ambiente Unix/Linux/macOS ou WSL.
- **Sem gerenciador de segredos real.** Secrets são lidos de variáveis de ambiente — em produção, prefira integrações com AWS Secrets Manager, HashiCorp Vault ou similar.
- **Testes Bash têm cobertura limitada.** Funções que dependem de estado do sistema (filesystem real, rede) são difíceis de isolar completamente. Os testes cobrem o comportamento das bibliotecas, não fluxos de integração end-to-end.
- **Módulos de negócio ainda genéricos.** `backup.sh` e `notify.sh` são pontos de partida — precisam ser adaptados para os caminhos e serviços reais de cada projeto.
- **`confirm()` não funciona em ambientes sem terminal.** Use `AUTO_CONFIRM=true` em CI/CD.
- **Sem rotação de log automática.** Em uso prolongado, configure `logrotate` no sistema operacional para gerenciar o arquivo de log.

---

## Pré-requisitos

| Ferramenta | Versão mínima | Finalidade |
|---|---|---|
| bash | 4.0+ | Execução dos scripts |
| curl | qualquer | Módulo de notificação |
| tar | qualquer | Módulo de backup |
| [bats-core](https://github.com/bats-core/bats-core) | 1.0+ | Rodar a suite de testes |
| [shellcheck](https://www.shellcheck.net/) | qualquer | Lint estático dos scripts |

---

## Como rodar

### Ambiente de desenvolvimento

```bash
bash main.sh -e dev
```

### Ambiente de desenvolvimento com modo verbose

```bash
bash main.sh -e dev -v
```

### Ambiente de produção

```bash
bash main.sh -e prod
```

### Sem prompt de confirmação (CI/CD)

```bash
AUTO_CONFIRM=true bash main.sh -e prod
```

### Com notificação Slack

```bash
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/..." bash main.sh -e prod
```

### Exibir ajuda

```bash
bash main.sh -h
```

---

## Variáveis de ambiente

Todas as variáveis têm valor padrão definido em `config/config.sh` e podem ser sobrescritas via ambiente ou pelo arquivo de config do ambiente escolhido.

| Variável | Padrão (dev) | Descrição |
|---|---|---|
| `AMBIENTE` | `dev` | Ambiente de execução (`dev` ou `prod`) |
| `VERBOSE` | `false` (dev: `true`) | Exibe mensagens DEBUG no terminal |
| `AUTO_CONFIRM` | `false` | Pula prompts de confirmação interativos |
| `LOG_ARQUIVO` | `/tmp/myapp-dev.log` | Caminho do arquivo de log |
| `BACKUP_ORIGEM` | `/tmp/myapp_origem` | Diretório de origem do backup |
| `BACKUP_DESTINO` | `/tmp/myapp_backup` | Diretório de destino do backup |
| `SLACK_WEBHOOK_URL` | _(vazio)_ | URL do webhook para notificações (opcional) |

---

## Como adicionar um módulo

1. Crie `modules/meu_modulo.sh` com uma função `meu_modulo_run`:

```bash
#!/bin/bash
meu_modulo_run() {
  log_info "Executando meu módulo"
  # sua lógica aqui
}
```

2. Adicione o nome do módulo à whitelist em `lib/runner.sh`:

```bash
MODULOS_PERMITIDOS=(check_deps backup notify meu_modulo)
```

3. Adicione ao pipeline em `main.sh`:

```bash
PIPELINE=(check_deps backup notify meu_modulo)
```

---

## Testes

### Instalar bats-core

```bash
git clone https://github.com/bats-core/bats-core /tmp/bats
sudo /tmp/bats/install.sh /usr/local
```

### Criar fixtures necessárias para o módulo de backup

```bash
mkdir -p /tmp/myapp_origem /tmp/myapp_backup
touch /tmp/myapp_origem/dado.txt
```

### Rodar todos os testes

```bash
bats tests/
```

### Rodar um arquivo de teste específico

```bash
bats tests/test_log.bats
```

---

## Linting

### Instalar shellcheck

```bash
# Ubuntu/Debian
sudo apt-get install shellcheck

# macOS
brew install shellcheck
```

### Rodar manualmente

```bash
shellcheck main.sh lib/*.sh modules/*.sh config/*.sh
```

O shellcheck também roda automaticamente como hook de pre-commit (`.git/hooks/pre-commit`) e no pipeline de CI a cada push.
