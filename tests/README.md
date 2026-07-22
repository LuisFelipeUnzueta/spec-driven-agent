# Como rodar os testes

## Requisitos

- PowerShell 5.1+
- Pester 3.4.0+ (`Get-Module -ListAvailable -Name Pester`)

## Execucao

```powershell
# Todos os testes
Invoke-Pester -Path ./tests/

# Um arquivo especifico
Invoke-Pester -Path ./tests/sync-claude.Tests.ps1

# Com output detalhado
Invoke-Pester -Path ./tests/ -Verbose
```

## Estrutura

```
tests/
├── sync-claude.Tests.ps1            # 9 testes — copia de framework para .claude/
├── generate-agents-md.Tests.ps1     # 7 testes — geracao do AGENTS.md
├── init-project.Tests.ps1           # 5 testes — orquestracao de inicializacao
└── fixtures/
    ├── mock-framework/              # Fonte simulada (agents/, rules/, skills/)
    ├── clean-project/               # Projeto vazio (sem .claude/)
    ├── empty-project/               # Projeto sem nenhum diretorio
    └── project-with-overrides/      # Projeto com .claude/ e overrides locais
```

## Fixtures

Os fixtures sao estruturas minimas que simulam um projeto real. Cada teste cria um diretorio temporario (via `TestDrive:`) e copia os fixtures necessarios, garantindo isolamento entre testes.
