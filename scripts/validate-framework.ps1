<#
.SYNOPSIS
    Valida portabilidade, estrutura e orçamento de contexto do framework v2.
#>
param()

$ErrorActionPreference = "Stop"
$repoRoot = (Get-Item -LiteralPath (Join-Path $PSScriptRoot "..")).FullName
$skillsRoot = Join-Path $repoRoot "framework\skills"
$rolesRoot = Join-Path $repoRoot "framework\roles"
$errors = New-Object System.Collections.Generic.List[string]
$totalDescriptionChars = 0

# Template registry validation
$registryPath = Join-Path $skillsRoot "_shared\config\template-registry.json"
if (-not (Test-Path -LiteralPath $registryPath)) {
    [void]$errors.Add("Template registry ausente: $registryPath.")
} else {
    try {
        $registry = [IO.File]::ReadAllText($registryPath) | ConvertFrom-Json
        if (-not $registry.version -or $registry.version -lt 1) {
            [void]$errors.Add("Template registry version invalida.")
        }
        if (-not $registry.templates -or @($registry.templates).Count -lt 25) {
            [void]$errors.Add("Template registry com menos de 25 templates: $(@($registry.templates).Count).")
        }
        $registryIds = [System.Collections.Generic.HashSet[string]]::new()
        foreach ($tpl in $registry.templates) {
            if (-not $tpl.id -or -not $tpl.path -or -not $tpl.owner -or -not $tpl.syntax) {
                [void]$errors.Add("Template registry: entrada incompleta (id='$($tpl.id)').")
                continue
            }
            if (-not $registryIds.Add($tpl.id)) {
                [void]$errors.Add("Template registry: ID duplicado '$($tpl.id)'.")
            }

            # Validate that each core template file exists
            $resolvedPath = [IO.Path]::GetFullPath((Join-Path $repoRoot $tpl.path.Replace('.agents', 'framework')))
            if (-not (Test-Path -LiteralPath $resolvedPath)) {
                [void]$errors.Add("Template registry: path nao encontrado para id='$($tpl.id)': $resolvedPath")
            }
        }
        # Validate resolution order
        $validOrder = @('overrides', 'presets', 'extensions', 'core')
        if (-not $registry.resolution_order -or @($registry.resolution_order).Count -ne 4) {
            [void]$errors.Add("Template registry: resolution_order deve ter 4 niveis.")
        } else {
            foreach ($level in $registry.resolution_order) {
                if ($level -notin $validOrder) {
                    [void]$errors.Add("Template registry: nivel desconhecido em resolution_order: '$level'.")
                }
            }
        }
    } catch {
        [void]$errors.Add("Template registry JSON invalido: $($_.Exception.Message)")
    }
}

# Validate template-registry references in SKILL.md files
$expectedRegistryRefs = @(
    'sda-adr-create', 'sda-adr-bootstrap', 'sda-adr-supersede',
    'sda-challenge-spec', 'sda-design-system-bootstrap', 'sda-generate-claude-md',
    'sda-generate-design', 'sda-minispec-generate-intent', 'sda-minispec-generate-scope',
    'sda-minispec-generate-tasks', 'sda-pre-refinement', 'sda-sdd-generate-prd',
    'sda-sdd-generate-task-plan', 'sda-sdd-generate-tech-spec', 'sda-taskcard-generate',
    'sda-debt-resolution', 'sda-readme-generator'
)
foreach ($skillName in $expectedRegistryRefs) {
    $skillPath = Join-Path $skillsRoot "$skillName\SKILL.md"
    if (-not (Test-Path -LiteralPath $skillPath)) {
        [void]$errors.Add("Skill esperada nao encontrada: $skillPath")
        continue
    }
    $text = [IO.File]::ReadAllText($skillPath)
    if ($text -notmatch 'sda-template-resolve') {
        [void]$errors.Add("Skill nao referencia sda-template-resolve: $skillName")
    }
}

foreach ($skill in Get-ChildItem -LiteralPath $skillsRoot -Recurse -File -Filter "SKILL.md") {
    $text = [IO.File]::ReadAllText($skill.FullName)
    $lines = $text -split "\r?\n"
    if ($lines.Count -gt 500) {
        [void]$errors.Add("SKILL acima de 500 linhas: $($skill.FullName) ($($lines.Count)).")
    }

    $frontmatter = [regex]::Match($text, '(?s)^---\s*\r?\n(?<body>.*?)\r?\n---')
    if (-not $frontmatter.Success) {
        [void]$errors.Add("Frontmatter ausente: $($skill.FullName).")
        continue
    }

    $fields = [regex]::Matches($frontmatter.Groups['body'].Value, '(?m)^([A-Za-z0-9_-]+):') | ForEach-Object { $_.Groups[1].Value }
    $unexpected = @($fields | Where-Object { $_ -notin @('name','description') })
    if ($unexpected.Count -gt 0) {
        [void]$errors.Add("Frontmatter não portável em $($skill.FullName): $($unexpected -join ', ').")
    }

    $descriptionMatch = [regex]::Match($frontmatter.Groups['body'].Value, '(?m)^description:\s*(.+)$')
    if (-not $descriptionMatch.Success) {
        [void]$errors.Add("Description ausente: $($skill.FullName).")
    } else {
        $length = $descriptionMatch.Groups[1].Value.Trim().Length
        $totalDescriptionChars += $length
        if ($length -gt 200) {
            [void]$errors.Add("Description acima de 200 caracteres: $($skill.FullName) ($length).")
        }
    }
}

# Examples repository validation
$examplesManifestPath = Join-Path $repoRoot "framework\references\examples\examples-manifest.json"
if (-not (Test-Path -LiteralPath $examplesManifestPath)) {
    [void]$errors.Add("Examples manifest ausente: $examplesManifestPath.")
} else {
    try {
        $examplesManifest = [IO.File]::ReadAllText($examplesManifestPath) | ConvertFrom-Json
        if (-not $examplesManifest.version -or $examplesManifest.version -lt 1) {
            [void]$errors.Add("Examples manifest version invalida.")
        }
        if (-not $examplesManifest.examples -or @($examplesManifest.examples).Count -lt 5) {
            [void]$errors.Add("Examples manifest com menos de 5 exemplos: $(@($examplesManifest.examples).Count).")
        }
        $exampleIds = [System.Collections.Generic.HashSet[string]]::new()
        foreach ($ex in $examplesManifest.examples) {
            if (-not $ex.id -or -not $ex.path -or -not $ex.stack) {
                [void]$errors.Add("Examples manifest: entrada incompleta (id='$($ex.id)').")
                continue
            }
            if (-not $exampleIds.Add($ex.id)) {
                [void]$errors.Add("Examples manifest: ID duplicado '$($ex.id)'.")
            }
            # Validate that each example file exists
            $exPath = [IO.Path]::GetFullPath((Join-Path $repoRoot "framework\references\examples\$($ex.path)"))
            if (-not (Test-Path -LiteralPath $exPath)) {
                [void]$errors.Add("Examples manifest: arquivo nao encontrado para id='$($ex.id)': $exPath")
            }
        }
    } catch {
        [void]$errors.Add("Examples manifest JSON invalido: $($_.Exception.Message)")
    }
}

# Checklist validation
$checklistSkillPath = Join-Path $skillsRoot "sda-checklist-generate\SKILL.md"
if (-not (Test-Path -LiteralPath $checklistSkillPath)) {
    [void]$errors.Add("sda-checklist-generate skill ausente: $checklistSkillPath.")
} else {
    $checklistAssets = @(
        "checklist-prd.md", "checklist-intent.md",
        "checklist-tech-spec.md", "checklist-scope.md"
    )
    foreach ($asset in $checklistAssets) {
        $assetPath = Join-Path (Split-Path $checklistSkillPath -Parent) "assets\$asset"
        if (-not (Test-Path -LiteralPath $assetPath)) {
            [void]$errors.Add("Checklist asset ausente: $assetPath")
        }
    }
}

if ($totalDescriptionChars -ge 8000) {
    [void]$errors.Add("Catálogo de skills excede 8.000 caracteres: $totalDescriptionChars.")
}

$coreFiles = @(
    Get-ChildItem -LiteralPath $skillsRoot -Recurse -File -Filter "SKILL.md"
    Get-ChildItem -LiteralPath (Join-Path $skillsRoot "_shared") -Recurse -File -Include "*.md","*.json"
    Get-ChildItem -LiteralPath $rolesRoot -Recurse -File -Include "*.md","*.json"
)
$forbidden = @(
    @{ Pattern='\.claude/|\.codex/|(?i)\bClaude Code\b|\bOpenAI Codex\b'; Label='referencia especifica de host' },
    @{ Pattern='\bAskUserQuestion\b|\bAgent\s*\('; Label='ferramenta especifica de host' },
    @{ Pattern='\$ARGUMENTS'; Label='placeholder especifico de host' },
    @{ Pattern='(?i)\bsonnet\b|\bopus\b|\bhaiku\b'; Label='alias de modelo no nucleo comum' },
    @{ Pattern='skills?sda-|rules?sda-|roles?sda-|\.agentssda-'; Label='path SDA concatenado' },
    @{ Pattern='(?i)system-prompt|system prompt'; Label='premissa de carregamento automatico' }
)
foreach ($file in $coreFiles) {
    $text = [IO.File]::ReadAllText($file.FullName)
    foreach ($rule in $forbidden) {
        if ($text -match $rule.Pattern) {
            [void]$errors.Add("$($rule.Label) em $($file.FullName).")
        }
    }
}

foreach ($template in Get-ChildItem -LiteralPath $skillsRoot -Recurse -File -Filter "*.md" | Where-Object { $_.Name -match 'template' }) {
    $text = [IO.File]::ReadAllText($template.FullName)
    if ($text -match '(?im)^\s*-?\s*(\*\*)?(model|reasoning_effort|gates)(\*\*)?\s*:') {
        [void]$errors.Add("Campo de task v1 em template: $($template.FullName).")
    }
}

foreach ($candidate in Get-ChildItem -LiteralPath $skillsRoot -Recurse -File -Filter "*.md") {
    if ($candidate.Length -gt 200) { continue }
    $content = [IO.File]::ReadAllText($candidate.FullName).Trim()
    if ($content -match '^\.\.?[/\\].+\.md$') {
        [void]$errors.Add("Placeholder de symlink detectado: $($candidate.FullName).")
    }
}

$linkFiles = Get-ChildItem -LiteralPath $repoRoot -Recurse -File -Filter "*.md" | Where-Object {
    $_.FullName -like "$repoRoot\framework\*" -and
    $_.FullName -notmatch '[\\/](assets|templates)[\\/]'
}
foreach ($file in $linkFiles) {
    $content = [IO.File]::ReadAllText($file.FullName)
    $content = [regex]::Replace($content, '(?s)```.*?```', '')
    $content = [regex]::Replace($content, '`[^`\r\n]*`', '')
    foreach ($match in [regex]::Matches($content, '(?<!\!)\[[^\]]+\]\((?<target>[^)]+)\)')) {
        $target = $match.Groups['target'].Value.Trim()
        if ($target -match '^(https?://|mailto:|#)' -or $target -match '[{}<>]') {
            continue
        }

        $pathPart = ($target -split '#', 2)[0]
        if (-not $pathPart) { continue }
        $resolvedTarget = [IO.Path]::GetFullPath((Join-Path $file.DirectoryName $pathPart))
        if (-not (Test-Path -LiteralPath $resolvedTarget)) {
            [void]$errors.Add("Link local quebrado em $($file.FullName): $target")
        }
    }
}

foreach ($jsonFile in Get-ChildItem -LiteralPath (Join-Path $repoRoot "framework") -Recurse -File -Filter "*.json") {
    try { [void]([IO.File]::ReadAllText($jsonFile.FullName) | ConvertFrom-Json) }
    catch { [void]$errors.Add("JSON invalido: $($jsonFile.FullName): $($_.Exception.Message)") }
}

$profilesPath = Join-Path $repoRoot "framework\adapters\profiles.json"
try {
    $profiles = [IO.File]::ReadAllText($profilesPath) | ConvertFrom-Json
} catch {
    [void]$errors.Add("profiles.json invalido: $($_.Exception.Message)")
    $profiles = $null
}

foreach ($roleDirectory in Get-ChildItem -LiteralPath $rolesRoot -Directory) {
    $metadataPath = Join-Path $roleDirectory.FullName "role.json"
    $instructionsPath = Join-Path $roleDirectory.FullName "ROLE.md"
    if (-not (Test-Path -LiteralPath $metadataPath) -or -not (Test-Path -LiteralPath $instructionsPath)) {
        [void]$errors.Add("Papel incompleto: $($roleDirectory.FullName)")
        continue
    }

    try { $role = [IO.File]::ReadAllText($metadataPath) | ConvertFrom-Json }
    catch { [void]$errors.Add("role.json invalido: $metadataPath"); continue }
    if (-not $role.name -or -not $role.description -or -not $role.profile) {
        [void]$errors.Add("Campos obrigatorios ausentes em: $metadataPath")
    }
    if ($profiles -and (-not $profiles.providers.claude.profiles.$($role.profile) -or -not $profiles.providers.codex.profiles.$($role.profile))) {
        [void]$errors.Add("Perfil '$($role.profile)' indisponivel nos dois hosts: $metadataPath")
    }
}

$hostEvalsPath = Join-Path $repoRoot "framework\evals\host-compatibility.json"
try {
    $hostEvals = [IO.File]::ReadAllText($hostEvalsPath) | ConvertFrom-Json
    if (@($hostEvals.hosts).Count -ne 2 -or 'claude' -notin @($hostEvals.hosts) -or 'codex' -notin @($hostEvals.hosts) -or @($hostEvals.scenarios).Count -lt 4) {
        [void]$errors.Add("Evals equivalentes de host incompletos: $hostEvalsPath")
    }
} catch { [void]$errors.Add("Evals de host invalidos: $hostEvalsPath") }

$qaRoot = Join-Path $rolesRoot "sda-qa-validator"
$normalQaBytes = (Get-Item (Join-Path $qaRoot "ROLE.md")).Length + (Get-Item (Join-Path $qaRoot "references\core.md")).Length + (Get-Item (Join-Path $qaRoot "references\output-schema.json")).Length
$criticalQaBytes = (Get-ChildItem -LiteralPath $qaRoot -Recurse -File | Measure-Object Length -Sum).Sum
if ($normalQaBytes -gt 25KB) { [void]$errors.Add("QA comum excede 25 KB: $normalQaBytes bytes.") }
if ($criticalQaBytes -gt 45KB) { [void]$errors.Add("QA crítico excede 45 KB: $criticalQaBytes bytes.") }


if ($errors.Count -gt 0) {
    throw ("Validação do framework falhou:`n- " + ($errors -join "`n- "))
}

[pscustomobject]@{
    Skills = @(Get-ChildItem -LiteralPath $skillsRoot -Recurse -File -Filter "SKILL.md").Count
    DescriptionChars = $totalDescriptionChars
    NormalQaBytes = $normalQaBytes
    CriticalQaBytes = $criticalQaBytes
    Status = "OK"
}