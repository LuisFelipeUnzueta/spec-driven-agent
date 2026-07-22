Describe "generate-agents-md.ps1" {

    $scriptPath = Join-Path $PSScriptRoot "..\scripts\generate-agents-md.ps1"

    BeforeAll {
        $frameworkPath = Join-Path $PSScriptRoot "fixtures\mock-framework"
    }

    It "Gera AGENTS.md com header correto" {
        $projectDir = Join-Path $TestDrive "test-gen-header"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        $output = Get-Content (Join-Path $projectDir "AGENTS.md") -Raw
        $output | Should Match "# AGENTS\.md"
        $output | Should Match "Visao Geral"
    }

    It "Lista agents do framework" {
        $projectDir = Join-Path $TestDrive "test-gen-agents"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        $output = Get-Content (Join-Path $projectDir "AGENTS.md") -Raw
        $output | Should Match "sda-test-agent"
    }

    It "Lista rules do framework" {
        $projectDir = Join-Path $TestDrive "test-gen-rules"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        $output = Get-Content (Join-Path $projectDir "AGENTS.md") -Raw
        $output | Should Match "sda-test-rule"
    }

    It "Lista skills do framework" {
        $projectDir = Join-Path $TestDrive "test-gen-skills"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        $output = Get-Content (Join-Path $projectDir "AGENTS.md") -Raw
        $output | Should Match "sda-test-skill"
    }

    It "Inclui overrides locais (.agents/)" {
        $projectDir = Join-Path $TestDrive "test-gen-overrides"
        $agentsDir = Join-Path $projectDir ".agents\rules"
        New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null
        "regra local" | Out-File (Join-Path $agentsDir "my-project-rule.md") -Encoding UTF8

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        $output = Get-Content (Join-Path $projectDir "AGENTS.md") -Raw
        $output | Should Match "my-project-rule"
        $output | Should Match "Especificas do Projeto"
    }

    It "Gera output em path customizado" {
        $projectDir = Join-Path $TestDrive "test-gen-custom"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
        $customPath = Join-Path $projectDir "docs\AGENTS.md"

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath -OutputPath $customPath

        Test-Path $customPath | Should Be $true
    }

    It "Erro claro se framework nao existe" {
        $badPath = Join-Path $TestDrive "nao-existe"
        { & $scriptPath -ProjectPath $TestDrive -FrameworkPath $badPath } | Should Throw
    }
}
