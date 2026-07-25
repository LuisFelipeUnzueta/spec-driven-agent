<#
.SYNOPSIS
    Migra tasks SpecDrivenAgent v1 para o contrato v2.
.DESCRIPTION
    Converte `gates` em `validation`, remove `model` e `reasoning_effort` e
    aborta antes de escrever quando encontra valor inválido ou task sem risk.
#>
param(
    [string]$ProjectPath = ".",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
    throw "Projeto não encontrado: $ProjectPath"
}

$projectRoot = (Get-Item -LiteralPath $ProjectPath).FullName
$docsRoot = Join-Path $projectRoot "docs\specs"
if (-not (Test-Path -LiteralPath $docsRoot -PathType Container)) {
    Write-Host "Nenhuma pasta docs/specs encontrada; nada para migrar."
    return
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$changes = New-Object System.Collections.Generic.List[object]
$errors = New-Object System.Collections.Generic.List[string]

foreach ($file in Get-ChildItem -LiteralPath $docsRoot -Recurse -File -Filter "*.md") {
    $original = [IO.File]::ReadAllText($file.FullName)
    $output = New-Object System.Collections.Generic.List[string]
    $convertedValidation = $false
    $removedLegacyField = $false

    foreach ($line in ($original -split "\r?\n", 0, "RegexMatch")) {
        $legacyField = [regex]::Match($line, '^\s*-?\s*(\*\*)?(model|reasoning_effort)(\*\*)?\s*:', 'IgnoreCase')
        if ($legacyField.Success) {
            $removedLegacyField = $true
            continue
        }

        $gate = [regex]::Match(
            $line,
            '^(?<indent>\s*-?\s*)(?<bold>\*\*)?gates(?<boldEnd>\*\*)?\s*:\s*(?<value>\[[^\]]+\]|none)(?<suffix>.*)$',
            'IgnoreCase'
        )

        if ($gate.Success) {
            $normalized = ($gate.Groups['value'].Value -replace '\s+', '').ToLowerInvariant()
            $validation = switch ($normalized) {
                '[qa,tech_review]' { 'full' }
                '[qa]' { 'qa' }
                'none' { 'none' }
                default { $null }
            }

            if (-not $validation) {
                [void]$errors.Add("$($file.FullName): validation v1 inválida '$($gate.Groups['value'].Value)'.")
                [void]$output.Add($line)
                continue
            }

            $key = if ($gate.Groups['bold'].Success) { '**validation**' } else { 'validation' }
            [void]$output.Add($gate.Groups['indent'].Value + $key + ': ' + $validation + $gate.Groups['suffix'].Value)
            $convertedValidation = $true
            continue
        }

        if ($line -match '^\s*-?\s*(\*\*)?gates(\*\*)?\s*:') {
            [void]$errors.Add("$($file.FullName): campo gates não reconhecido: $line")
        }

        [void]$output.Add($line)
    }

    if ($convertedValidation) {
        $hasRisk = $output | Where-Object { $_ -match '^\s*-?\s*(\*\*)?risk(\*\*)?\s*:\s*(low|medium|high)\b' }
        if (-not $hasRisk) {
            [void]$errors.Add("$($file.FullName): task migrada sem risk low|medium|high.")
        }
    }

    if ($convertedValidation -or $removedLegacyField) {
        $newContent = ($output -join [Environment]::NewLine).TrimEnd() + [Environment]::NewLine
        [void]$changes.Add([pscustomobject]@{ Path=$file.FullName; Content=$newContent })
    }
}

if ($errors.Count -gt 0) {
    throw ("Migração abortada sem alterações:`n- " + ($errors -join "`n- "))
}

foreach ($change in $changes) {
    $relative = $change.Path.Substring($projectRoot.Length).TrimStart([char[]]"\/")
    if ($DryRun) {
        Write-Host "[DRY-RUN] MIGRATE $relative"
    } else {
        [IO.File]::WriteAllText($change.Path, $change.Content, $utf8NoBom)
        Write-Host "[MIGRATE] $relative" -ForegroundColor Green
    }
}

Write-Host "$($changes.Count) arquivo(s) elegível(is) para migração v2."