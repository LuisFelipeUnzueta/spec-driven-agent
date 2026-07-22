<#
.SYNOPSIS
    Inicializa o SpecDrivenAgent em um projeto existente.
.DESCRIPTION
    Cria estrutura de override, sincroniza framework, gera AGENTS.md e cria CLAUDE.md basico.
.PARAMETER ProjectPath
    Caminho do projeto-alvo.
.PARAMETER FrameworkPath
    Caminho do SpecDrivenAgent.
#>
param(
    [string]$ProjectPath = ".",
    [string]$FrameworkPath = ""
)

$ErrorActionPreference = "Stop"

if (-not $FrameworkPath) {
    $FrameworkPath = Join-Path $PSScriptRoot ".."
}

Write-Host "=== SpecDrivenAgent - Inicializar Projeto ===" -ForegroundColor Cyan

# 1. Criar estrutura de override
$dirs = @(
    (Join-Path $ProjectPath ".agents\rules"),
    (Join-Path $ProjectPath ".agents\skills")
)
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Criado: $dir" -ForegroundColor Green
    }
}

# 2. Sincronizar framework
Write-Host ""
Write-Host "Sincronizando framework..." -ForegroundColor Yellow
& (Join-Path $PSScriptRoot "sync-claude.ps1") -ProjectPath $ProjectPath -FrameworkPath (Join-Path $FrameworkPath "framework")

# 3. Gerar AGENTS.md
Write-Host ""
Write-Host "Gerando AGENTS.md..." -ForegroundColor Yellow
& (Join-Path $PSScriptRoot "generate-agents-md.ps1") -ProjectPath $ProjectPath -FrameworkPath (Join-Path $FrameworkPath "framework")

# 4. Criar CLAUDE.md basico se nao existir
$claudeMd = Join-Path $ProjectPath "CLAUDE.md"
if (-not (Test-Path $claudeMd)) {
    $claudeContent = @"
# CLAUDE.md

## Regras do Projeto
Consulte `.claude/rules/` para regras de arquitetura e coding standards.

## Skills Disponiveis
Consulte `.claude/skills/` para skills do framework SpecDrivenAgent.

## Fluxo de Trabalho
1. Execute `/sda-guide` para ver todas as skills disponiveis
2. Use `/sda-pre-refinement` para descobrir qual workflow usar
3. Siga as rules em `.claude/rules/` durante implementacao
"@
    $claudeContent | Out-File -FilePath $claudeMd -Encoding UTF8
    Write-Host "CLAUDE.md criado: $claudeMd" -ForegroundColor Green
}

Write-Host ""
Write-Host "Inicializacao concluida!" -ForegroundColor Green
Write-Host "Proximos passos:"
Write-Host "  1. Revise os arquivos em .claude/"
Write-Host "  2. Adicione overrides em .agents/rules/ e .agents/skills/"
Write-Host "  3. Execute /sda-guide para ver as skills disponiveis"
