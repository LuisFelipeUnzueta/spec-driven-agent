<#
.SYNOPSIS
    Projeta o núcleo do SpecDrivenAgent v2 para Claude Code, Codex ou ambos.
.DESCRIPTION
    Mantém `.agents/skills` como projeção comum, gera adapters de agentes por
    host e atualiza apenas blocos gerenciados em AGENTS.md e CLAUDE.md.
.PARAMETER TargetHost
    Claude, Codex ou Both. Aceita o alias público -Host.
.PARAMETER DryRun
    Exibe cópias, renders e remoções sem alterar o projeto.
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
    $FrameworkPath = Join-Path $PSScriptRoot "..\framework"
}

if (-not (Test-Path -LiteralPath $ProjectPath -PathType Container)) {
    throw "Projeto não encontrado: $ProjectPath"
}

if (-not (Test-Path -LiteralPath $FrameworkPath -PathType Container)) {
    throw "Framework não encontrado: $FrameworkPath"
}

$projectRoot = (Get-Item -LiteralPath $ProjectPath).FullName.TrimEnd("\", "/")
$frameworkRoot = (Get-Item -LiteralPath $FrameworkPath).FullName.TrimEnd("\", "/")
$manifestPath = Join-Path $projectRoot ".agents\.sda-manifest.json"
$generatedFiles = New-Object System.Collections.Generic.List[string]
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Get-RelativeProjectPath {
    param([string]$Path)

    $fullPath = [IO.Path]::GetFullPath($Path)
    if ($fullPath -eq $projectRoot) {
        return "."
    }

    $prefix = $projectRoot + [IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Path fora do projeto: $fullPath"
    }

    return $fullPath.Substring($prefix.Length).Replace("\", "/")
}

function Ensure-Directory {
    param([string]$Path)

    if ($DryRun -or (Test-Path -LiteralPath $Path -PathType Container)) {
        return
    }

    [void](New-Item -ItemType Directory -Path $Path -Force)
}

function Write-GeneratedFile {
    param(
        [string]$Destination,
        [string]$Content
    )

    $relative = Get-RelativeProjectPath -Path $Destination
    [void]$generatedFiles.Add($relative)

    if ($DryRun) {
        Write-Host "[DRY-RUN] WRITE $relative"
        return
    }

    Ensure-Directory -Path (Split-Path -Parent $Destination)
    [IO.File]::WriteAllText($Destination, $Content, $utf8NoBom)
    Write-Host "[WRITE] $relative" -ForegroundColor Green
}

function Copy-GeneratedFile {
    param(
        [string]$Source,
        [string]$Destination
    )

    if ((Split-Path -Leaf $Source) -eq ".DS_Store") {
        return
    }

    $relative = Get-RelativeProjectPath -Path $Destination
    [void]$generatedFiles.Add($relative)

    if ($DryRun) {
        Write-Host "[DRY-RUN] COPY $relative"
        return
    }

    Ensure-Directory -Path (Split-Path -Parent $Destination)
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    Write-Host "[COPY] $relative" -ForegroundColor Green
}

function Copy-GeneratedTree {
    param(
        [string]$SourceRoot,
        [string]$DestinationRoot
    )

    if (-not (Test-Path -LiteralPath $SourceRoot -PathType Container)) {
        return
    }

    foreach ($file in Get-ChildItem -LiteralPath $SourceRoot -Recurse -Force -File) {
        if ($file.Name -eq ".DS_Store") {
            continue
        }

        $relative = $file.FullName.Substring($SourceRoot.Length).TrimStart([char[]]"\/")
        Copy-GeneratedFile -Source $file.FullName -Destination (Join-Path $DestinationRoot $relative)
    }
}

function Escape-YamlDoubleQuoted {
    param([string]$Value)

    return $Value.Replace("\", "\\").Replace('"', '\"').Replace("`r", "").Replace("`n", "\n")
}

function Escape-TomlString {
    param([string]$Value)

    return $Value.Replace("\", "\\").Replace('"', '\"').Replace("`r", "").Replace("`n", "\n").Replace("`t", "\t")
}

function Get-Profile {
    param(
        [object]$Profiles,
        [string]$Provider,
        [string]$ProfileName
    )

    $providerProfiles = $Profiles.providers.$Provider.profiles
    $profile = $providerProfiles.$ProfileName
    if (-not $profile) {
        throw "Perfil '$ProfileName' não encontrado para '$Provider'."
    }

    return $profile
}

function Render-ClaudeAgent {
    param(
        [object]$Role,
        [string]$Instructions,
        [object]$Profile
    )

    $description = Escape-YamlDoubleQuoted -Value ([string]$Role.description)
    $lines = @(
        "---",
        "name: $($Role.name)",
        "description: `"$description`"",
        "model: $($Profile.model)",
        "effort: $($Profile.effort)",
        "---",
        "",
        $Instructions.Trim(),
        ""
    )

    return $lines -join [Environment]::NewLine
}

function Render-CodexAgent {
    param(
        [object]$Role,
        [string]$Instructions,
        [object]$Profile
    )

    $name = Escape-TomlString -Value ([string]$Role.name)
    $description = Escape-TomlString -Value ([string]$Role.description)
    $developerInstructions = Escape-TomlString -Value $Instructions.Trim()
    $lines = @(
        "name = `"$name`"",
        "description = `"$description`"",
        "model = `"$($Profile.model)`"",
        "model_reasoning_effort = `"$($Profile.effort)`"",
        "developer_instructions = `"$developerInstructions`"",
        ""
    )

    return $lines -join [Environment]::NewLine
}

function Update-ManagedBlock {
    param(
        [string]$Path,
        [string]$TemplatePath
    )

    $startMarker = "<!-- sda:start -->"
    $endMarker = "<!-- sda:end -->"
    $managed = [IO.File]::ReadAllText($TemplatePath).Trim()
    $existing = if (Test-Path -LiteralPath $Path) { [IO.File]::ReadAllText($Path) } else { "" }
    $startIndex = $existing.IndexOf($startMarker, [StringComparison]::Ordinal)
    $endIndex = $existing.IndexOf($endMarker, [StringComparison]::Ordinal)

    if (($startIndex -ge 0) -xor ($endIndex -ge 0)) {
        throw "Bloco gerenciado incompleto em: $Path"
    }

    if ($startIndex -ge 0) {
        if ($endIndex -lt $startIndex) {
            throw "Bloco gerenciado inválido em: $Path"
        }

        $endIndex += $endMarker.Length
        $before = $existing.Substring(0, $startIndex).TrimEnd()
        $after = $existing.Substring($endIndex).TrimStart()
        $parts = @($before, $managed, $after) | Where-Object { $_ }
        $result = ($parts -join ([Environment]::NewLine + [Environment]::NewLine)) + [Environment]::NewLine
    } else {
        $parts = @($existing.TrimEnd(), $managed) | Where-Object { $_ }
        $result = ($parts -join ([Environment]::NewLine + [Environment]::NewLine)) + [Environment]::NewLine
    }

    if ($DryRun) {
        Write-Host "[DRY-RUN] MANAGED $(Get-RelativeProjectPath -Path $Path)"
        return
    }

    Ensure-Directory -Path (Split-Path -Parent $Path)
    [IO.File]::WriteAllText($Path, $result, $utf8NoBom)
    Write-Host "[MANAGED] $(Get-RelativeProjectPath -Path $Path)" -ForegroundColor Green
}

function Remove-ManagedBlock {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return
    }

    $startMarker = "<!-- sda:start -->"
    $endMarker = "<!-- sda:end -->"
    $existing = [IO.File]::ReadAllText($Path)
    $startIndex = $existing.IndexOf($startMarker, [StringComparison]::Ordinal)
    $endIndex = $existing.IndexOf($endMarker, [StringComparison]::Ordinal)

    if ($startIndex -lt 0 -and $endIndex -lt 0) {
        return
    }
    if ($startIndex -lt 0 -or $endIndex -lt $startIndex) {
        throw "Bloco gerenciado invalido em: $Path"
    }

    $endIndex += $endMarker.Length
    $before = $existing.Substring(0, $startIndex).TrimEnd()
    $after = $existing.Substring($endIndex).TrimStart()
    $remaining = (@($before, $after) | Where-Object { $_ }) -join ([Environment]::NewLine + [Environment]::NewLine)

    if ($DryRun) {
        Write-Host "[DRY-RUN] UNMANAGED $(Get-RelativeProjectPath -Path $Path)"
        return
    }

    if ($remaining) {
        [IO.File]::WriteAllText($Path, $remaining + [Environment]::NewLine, $utf8NoBom)
    } else {
        Remove-Item -LiteralPath $Path -Force
    }
    Write-Host "[UNMANAGED] $(Get-RelativeProjectPath -Path $Path)" -ForegroundColor Yellow
}

function Remove-StaleGeneratedFiles {
    if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
        return
    }

    try {
        $oldManifest = [IO.File]::ReadAllText($manifestPath) | ConvertFrom-Json
    } catch {
        Write-Warning "Manifesto anterior inválido; limpeza stale ignorada."
        return
    }

    $current = @{}
    foreach ($path in $generatedFiles) {
        $current[$path.ToLowerInvariant()] = $true
    }

    foreach ($relative in @($oldManifest.generatedFiles)) {
        $normalized = ([string]$relative).Replace("/", "\")
        $destination = Join-Path $projectRoot $normalized
        [void](Get-RelativeProjectPath -Path $destination)

        if ($current.ContainsKey(([string]$relative).ToLowerInvariant())) {
            continue
        }

        if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) {
            continue
        }

        if ($DryRun) {
            Write-Host "[DRY-RUN] REMOVE $relative"
        } else {
            Remove-Item -LiteralPath $destination -Force
            Write-Host "[REMOVE] $relative" -ForegroundColor Yellow
        }
    }
}

$skillsSource = Join-Path $frameworkRoot "skills"
$rolesSource = Join-Path $frameworkRoot "roles"
$adaptersSource = Join-Path $frameworkRoot "adapters"
$templatesSource = Join-Path (Split-Path -Parent $frameworkRoot) "templates"
$profilesPath = Join-Path $adaptersSource "profiles.json"

if (-not (Test-Path -LiteralPath $profilesPath -PathType Leaf)) {
    throw "Perfis de host não encontrados: $profilesPath"
}

$profiles = [IO.File]::ReadAllText($profilesPath) | ConvertFrom-Json
Ensure-Directory -Path (Join-Path $projectRoot ".agents\rules")
Ensure-Directory -Path (Join-Path $projectRoot ".agents\skills")

foreach ($skillDirectory in Get-ChildItem -LiteralPath $skillsSource -Directory) {
    $isShared = $skillDirectory.Name -eq "_shared"
    $hasSkill = Test-Path -LiteralPath (Join-Path $skillDirectory.FullName "SKILL.md") -PathType Leaf
    if (-not $isShared -and -not $hasSkill) {
        continue
    }

    Copy-GeneratedTree -SourceRoot $skillDirectory.FullName -DestinationRoot (Join-Path $projectRoot (".agents\skills\" + $skillDirectory.Name))
    if ($TargetHost -in @("Claude", "Both")) {
        Copy-GeneratedTree -SourceRoot $skillDirectory.FullName -DestinationRoot (Join-Path $projectRoot (".claude\skills\" + $skillDirectory.Name))
    }
}

if ($TargetHost -in @("Claude", "Both")) {
    $localSkillsRoot = Join-Path $projectRoot ".agents\skills"
    foreach ($skillDirectory in Get-ChildItem -LiteralPath $localSkillsRoot -Directory -ErrorAction SilentlyContinue) {
        if ($skillDirectory.Name -like "sda-*" -or $skillDirectory.Name -eq "_shared") {
            continue
        }
        if (-not (Test-Path -LiteralPath (Join-Path $skillDirectory.FullName "SKILL.md") -PathType Leaf)) {
            continue
        }
        Copy-GeneratedTree -SourceRoot $skillDirectory.FullName -DestinationRoot (Join-Path $projectRoot (".claude\skills\" + $skillDirectory.Name))
    }
}

Copy-GeneratedTree -SourceRoot $rolesSource -DestinationRoot (Join-Path $projectRoot ".agents\roles")
Copy-GeneratedFile -Source $profilesPath -Destination (Join-Path $projectRoot ".agents\sda-profiles.json")

foreach ($roleDirectory in Get-ChildItem -LiteralPath $rolesSource -Directory) {
    $metadataPath = Join-Path $roleDirectory.FullName "role.json"
    $instructionsPath = Join-Path $roleDirectory.FullName "ROLE.md"
    if (-not (Test-Path -LiteralPath $metadataPath) -or -not (Test-Path -LiteralPath $instructionsPath)) {
        throw "Papel incompleto: $($roleDirectory.FullName)"
    }

    $role = [IO.File]::ReadAllText($metadataPath) | ConvertFrom-Json
    $instructions = [IO.File]::ReadAllText($instructionsPath)

    if ($TargetHost -in @("Claude", "Both")) {
        $profile = Get-Profile -Profiles $profiles -Provider "claude" -ProfileName $role.profile
        Write-GeneratedFile -Destination (Join-Path $projectRoot (".claude\agents\" + $role.name + ".md")) -Content (Render-ClaudeAgent -Role $role -Instructions $instructions -Profile $profile)
    }

    if ($TargetHost -in @("Codex", "Both")) {
        $profile = Get-Profile -Profiles $profiles -Provider "codex" -ProfileName $role.profile
        Write-GeneratedFile -Destination (Join-Path $projectRoot (".codex\agents\" + $role.name + ".toml")) -Content (Render-CodexAgent -Role $role -Instructions $instructions -Profile $profile)
    }
}

if ($TargetHost -in @("Claude", "Both")) {
    $rulesSource = Join-Path $projectRoot ".agents\rules"
    foreach ($rule in Get-ChildItem -LiteralPath $rulesSource -Recurse -Force -File -ErrorAction SilentlyContinue) {
        if ($rule.Name -eq ".DS_Store") {
            continue
        }
        $relative = $rule.FullName.Substring($rulesSource.Length).TrimStart([char[]]"\/")
        Copy-GeneratedFile -Source $rule.FullName -Destination (Join-Path $projectRoot (".claude\rules\" + $relative))
    }
}

Update-ManagedBlock -Path (Join-Path $projectRoot "AGENTS.md") -TemplatePath (Join-Path $templatesSource "AGENTS.md.template")
if ($TargetHost -in @("Claude", "Both")) {
    Update-ManagedBlock -Path (Join-Path $projectRoot "CLAUDE.md") -TemplatePath (Join-Path $templatesSource "CLAUDE.md.template")
} else {
    Remove-ManagedBlock -Path (Join-Path $projectRoot "CLAUDE.md")
}

Remove-StaleGeneratedFiles

if (-not $DryRun) {
    Ensure-Directory -Path (Split-Path -Parent $manifestPath)
    $versionFile = Join-Path (Split-Path -Parent $frameworkRoot) "VERSION"
    $version = if (Test-Path -LiteralPath $versionFile) { (Get-Content -Raw -LiteralPath $versionFile).Trim() } else { "dev" }
    $manifest = [ordered]@{
        version = $version
        targetHost = $TargetHost
        generatedFiles = @($generatedFiles | Sort-Object -Unique)
    }
    [IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 5) + [Environment]::NewLine, $utf8NoBom)
    Write-Host "[MANIFEST] .agents/.sda-manifest.json" -ForegroundColor Green
}