<#
.SYNOPSIS
    Gera o arquivo AGENTS.md para uso com OpenAI Codex.
.DESCRIPTION
    Consolida workflows, rules, skills e agents do SpecDrivenAgent em um unico AGENTS.md.
.PARAMETER ProjectPath
    Caminho do projeto-alvo. Padrao: diretorio atual.
.PARAMETER FrameworkPath
    Caminho do SpecDrivenAgent. Padrao: relativo ao script (../framework).
.PARAMETER OutputPath
    Caminho de saida do AGENTS.md. Padrao: raiz do projeto.
#>
param(
    [string]$ProjectPath = ".",
    [string]$FrameworkPath = "",
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"

if (-not $FrameworkPath) {
    $FrameworkPath = Join-Path $PSScriptRoot "..\framework"
}

if (-not $OutputPath) {
    $OutputPath = Join-Path $ProjectPath "AGENTS.md"
}

if (-not (Test-Path $FrameworkPath)) {
    Write-Error "Framework nao encontrado em: $FrameworkPath"
    exit 1
}

$FrameworkPath = Resolve-Path $FrameworkPath

Write-Host "=== SpecDrivenAgent - Gerar AGENTS.md ===" -ForegroundColor Cyan

# Listar agents
$agents = Get-ChildItem (Join-Path $FrameworkPath "agents") -Filter "*.md" -ErrorAction SilentlyContinue

# Listar rules
$rules = Get-ChildItem (Join-Path $FrameworkPath "rules") -Filter "*.md" -ErrorAction SilentlyContinue

# Listar skills
$skills = Get-ChildItem (Join-Path $FrameworkPath "skills") -Directory -ErrorAction SilentlyContinue

# Listar overrides locais
$localRules = @()
$localSkills = @()
$agentsDir = Join-Path $ProjectPath ".agents"
if (Test-Path (Join-Path $agentsDir "rules")) {
    $localRules = Get-ChildItem (Join-Path $agentsDir "rules") -Filter "*.md" -ErrorAction SilentlyContinue
}
if (Test-Path (Join-Path $agentsDir "skills")) {
    $localSkills = Get-ChildItem (Join-Path $agentsDir "skills") -Directory -ErrorAction SilentlyContinue
}

# Gerar conteudo
$sb = [System.Text.StringBuilder]::new()

[void]$sb.AppendLine("# AGENTS.md")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## Visao Geral")
[void]$sb.AppendLine("Framework de desenvolvimento assistido por IA (SpecDrivenAgent).")
[void]$sb.AppendLine("Workflows: SDD (features grandes), miniSpec (features medias), TaskCard (tarefas pontuais).")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## Regras do Projeto")
[void]$sb.AppendLine("- Consulte `.claude/rules/` para regras de arquitetura e coding standards")
foreach ($rule in $rules) {
    $name = $rule.BaseName -replace "\.md$", ""
    [void]$sb.AppendLine("- $name")
}
if ($localRules.Count -gt 0) {
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("## Regras Especificas do Projeto")
    foreach ($rule in $localRules) {
        $name = $rule.BaseName -replace "\.md$", ""
        [void]$sb.AppendLine("- $name")
    }
}
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## Skills Disponiveis")
[void]$sb.AppendLine("### Framework (SpecDrivenAgent)")
foreach ($skill in $skills) {
    $name = $skill.Name
    [void]$sb.AppendLine("- /$name")
}
if ($localSkills.Count -gt 0) {
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("### Especificas do Projeto")
    foreach ($skill in $localSkills) {
        $name = $skill.Name
        [void]$sb.AppendLine("- /$name")
    }
}
[void]$sb.AppendLine("")
[void]$sb.AppendLine("## Agents (Gates)")
foreach ($agent in $agents) {
    $name = $agent.BaseName -replace "\.md$", ""
    [void]$sb.AppendLine("- $name")
}

# Salvar
$sb.ToString() | Out-File -FilePath $OutputPath -Encoding UTF8
Write-Host "AGENTS.md gerado em: $OutputPath" -ForegroundColor Green
