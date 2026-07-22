<#
.SYNOPSIS
    Atualiza o framework SpecDrivenAgent em um projeto.
.DESCRIPTION
    Se framework/ existe localmente, copia as atualizacoes.
    Se .agent-spec/ e um submodule, faz pull e depois sync.
.PARAMETER ProjectPath
    Caminho do projeto-alvo.
.PARAMETER FrameworkPath
    Caminho do SpecDrivenAgent fonte.
#>
param(
    [string]$ProjectPath = ".",
    [string]$FrameworkPath = ""
)

$ErrorActionPreference = "Stop"

Write-Host "=== SpecDrivenAgent - Atualizar Framework ===" -ForegroundColor Cyan

# Verificar se ha submodule
$submodulePath = Join-Path $ProjectPath ".agent-spec"
if (Test-Path (Join-Path $submodulePath ".git")) {
    Write-Host "Detectado submodule, fazendo pull..." -ForegroundColor Yellow
    Push-Location $submodulePath
    git pull origin main
    Pop-Location
    $FrameworkPath = $submodulePath
}

if (-not $FrameworkPath) {
    Write-Error "FrameworkPath nao especificado e nenhum submodule encontrado."
    exit 1
}

# Re-sincronizar
Write-Host ""
Write-Host "Re-sincronizando..." -ForegroundColor Yellow
& (Join-Path $PSScriptRoot "sync-claude.ps1") -ProjectPath $ProjectPath -FrameworkPath (Join-Path $FrameworkPath "framework") -Force

# Re-gerar AGENTS.md
Write-Host ""
Write-Host "Re-gerando AGENTS.md..." -ForegroundColor Yellow
& (Join-Path $PSScriptRoot "generate-agents-md.ps1") -ProjectPath $ProjectPath -FrameworkPath (Join-Path $FrameworkPath "framework")

Write-Host ""
Write-Host "Atualizacao concluida!" -ForegroundColor Green
