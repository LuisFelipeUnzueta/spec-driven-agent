<#
.SYNOPSIS
    Sincroniza o framework SpecDrivenAgent para o diretorio .claude/ do projeto.
.DESCRIPTION
    Copia agents, rules e skills de framework/ para .claude/agents/, .claude/rules/, .claude/skills/.
    Nao sobrescreve arquivos de override locais (prefixo diferente de sda-).
.PARAMETER ProjectPath
    Caminho do projeto-alvo. Padrao: diretorio atual.
.PARAMETER FrameworkPath
    Caminho do SpecDrivenAgent. Padrao: relativo ao script (../framework).
.PARAMETER Force
    Forca sobrescrita de todos os arquivos.
#>
param(
    [string]$ProjectPath = ".",
    [string]$FrameworkPath = "",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Detectar caminho do framework
if (-not $FrameworkPath) {
    $FrameworkPath = Join-Path $PSScriptRoot "..\framework"
}

if (-not (Test-Path $FrameworkPath)) {
    Write-Error "Framework nao encontrado em: $FrameworkPath"
    exit 1
}

$FrameworkPath = Resolve-Path $FrameworkPath

Write-Host "=== SpecDrivenAgent - Sync Claude Code ===" -ForegroundColor Cyan
Write-Host "Framework: $FrameworkPath"
Write-Host "Projeto:   $(Resolve-Path $ProjectPath)"
Write-Host ""

# Mapeamento de destino
$mappings = @{
    "agents" = Join-Path $ProjectPath ".claude\agents"
    "rules"  = Join-Path $ProjectPath ".claude\rules"
    "skills" = Join-Path $ProjectPath ".claude\skills"
}

$totalSynced = 0
$totalSkipped = 0

foreach ($type in $mappings.Keys) {
    $srcDir = Join-Path $FrameworkPath $type
    $dstDir = $mappings[$type]

    if (-not (Test-Path $srcDir)) {
        Write-Warning "Diretorio nao encontrado: $srcDir"
        continue
    }

    # Criar destino se nao existir
    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }

    Write-Host "[$type]" -ForegroundColor Yellow

    # Copiar itens
    $items = Get-ChildItem -Path $srcDir -ErrorAction SilentlyContinue
    foreach ($item in $items) {
        $destItem = Join-Path $dstDir $item.Name

        # Verificar se e override local (prefixo diferente de sda-)
        if ((-not $Force) -and (Test-Path $destItem)) {
            if ($item.Name -notmatch "^sda-") {
                Write-Host "  [SKIP] Override local preservado: $($item.Name)" -ForegroundColor DarkGray
                $totalSkipped++
                continue
            }
        }

        if ($item.PSIsContainer) {
            # Diretorio (skill)
            Copy-Item -Recurse -Force $item.FullName $destItem
        } else {
            # Arquivo
            Copy-Item -Force $item.FullName $destItem
        }

        Write-Host "  [SYNC] $($item.Name)" -ForegroundColor Green
        $totalSynced++
    }
}

Write-Host ""
Write-Host "Sincronizacao concluida!" -ForegroundColor Green
Write-Host "  Sincronizados: $totalSynced"
Write-Host "  Pulados (overrides locais): $totalSkipped"
