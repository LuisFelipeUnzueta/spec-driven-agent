Describe "init-project.ps1" {

    $scriptPath = Join-Path $PSScriptRoot "..\scripts\init-project.ps1"

    BeforeAll {
        $frameworkPath = Join-Path $PSScriptRoot ".."
    }

    It "Cria .agents/rules/ e .agents/skills/" {
        $projectDir = Join-Path $TestDrive "test-init-dirs"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        Test-Path (Join-Path $projectDir ".agents\rules") | Should Be $true
        Test-Path (Join-Path $projectDir ".agents\skills") | Should Be $true
    }

    It "Chama sync-claude.ps1 — .claude/agents/ criado" {
        $projectDir = Join-Path $TestDrive "test-init-sync"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        Test-Path (Join-Path $projectDir ".claude\agents") | Should Be $true
        $agents = Get-ChildItem (Join-Path $projectDir ".claude\agents") -Filter "*.md" -ErrorAction SilentlyContinue
        $agents.Count | Should BeGreaterThan 0
    }

    It "Chama generate-agents-md.ps1 — AGENTS.md criado" {
        $projectDir = Join-Path $TestDrive "test-init-agentsmd"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        $agentsMd = Join-Path $projectDir "AGENTS.md"
        Test-Path $agentsMd | Should Be $true
        $content = Get-Content $agentsMd -Raw
        $content | Should Match "AGENTS\.md"
    }

    It "Cria CLAUDE.md basico se nao existe" {
        $projectDir = Join-Path $TestDrive "test-init-claudemd"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        $claudeMd = Join-Path $projectDir "CLAUDE.md"
        Test-Path $claudeMd | Should Be $true
        $content = Get-Content $claudeMd -Raw
        $content | Should Match "Regras do Projeto"
        $content | Should Match "sda-guide"
    }

    It "Nao sobrescreve CLAUDE.md existente" {
        $projectDir = Join-Path $TestDrive "test-init-preserve-claude"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
        "# Meu CLAUDE.md customizado" | Out-File (Join-Path $projectDir "CLAUDE.md") -Encoding UTF8

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        $content = Get-Content (Join-Path $projectDir "CLAUDE.md") -Raw
        $content | Should Match "customizado"
        $content | Should Not Match "Regras do Projeto"
    }
}
