<#
.SYNOPSIS
    Inicializa o SpecDrivenAgent v2 em um projeto.
.PARAMETER ProjectPath
    Caminho do projeto-alvo.
.PARAMETER FrameworkPath
    Raiz do repositório SpecDrivenAgent.
.PARAMETER TargetHost
    Host a projetar: Claude, Codex ou Both. Aceita o alias público -Host.
.PARAMETER DryRun
    Mostra as ações sem alterar arquivos.
#>
param(
    [string]$ProjectPath = ".",
    [string]$FrameworkPath = "",
    [Alias("Host")]
    [ValidateSet("Claude", "Codex", "Both")]
    [string]$TargetHost = "Both",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if (-not $FrameworkPath) {
    $FrameworkPath = Join-Path $PSScriptRoot ".."
}

if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
    throw "Projeto não encontrado: $ProjectPath"
}

if (-not (Test-Path -LiteralPath (Join-Path $FrameworkPath "framework") -PathType Container)) {
    throw "Framework não encontrado: $FrameworkPath"
}

$syncScript = Join-Path $PSScriptRoot "sync-project.ps1"
& $syncScript `
    -ProjectPath $ProjectPath `
    -FrameworkPath (Join-Path $FrameworkPath "framework") `
    -TargetHost $TargetHost `
    -DryRun:$DryRun

if (-not $DryRun) {
    $versionPath = Join-Path $FrameworkPath "VERSION"
    $version = if (Test-Path -LiteralPath $versionPath) {
        (Get-Content -Raw -LiteralPath $versionPath).Trim()
    } else {
        "dev"
    }

    Write-Host "SpecDrivenAgent v$version inicializado para $TargetHost." -ForegroundColor Green
}