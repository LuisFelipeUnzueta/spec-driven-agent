Describe "init-project.ps1" {
    $scriptPath = Join-Path $PSScriptRoot "..\scripts\init-project.ps1"
    $packagePath = Join-Path $PSScriptRoot "fixtures\mock-package"

    It "defaults to Both and creates a missing projection tree" {
        $projectDir = Join-Path $TestDrive "new project"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $packagePath

        Test-Path (Join-Path $projectDir "AGENTS.md") | Should Be $true
        Test-Path (Join-Path $projectDir "CLAUDE.md") | Should Be $true
        Test-Path (Join-Path $projectDir ".codex\agents\sda-test-reviewer.toml") | Should Be $true
        Test-Path (Join-Path $projectDir ".agents\skills\sda-test-skill\SKILL.md") | Should Be $true
    }

    It "accepts the public Host alias" {
        $projectDir = Join-Path $TestDrive "codex init"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $packagePath -Host Codex

        Test-Path (Join-Path $projectDir ".codex\agents\sda-test-reviewer.toml") | Should Be $true
        Test-Path (Join-Path $projectDir ".claude") | Should Be $false
    }

    It "throws when the project directory does not exist" {
        $didThrow = $false
        try { & $scriptPath -ProjectPath (Join-Path $TestDrive "missing") -FrameworkPath $packagePath } catch { $didThrow = $true }
        $didThrow | Should Be $true
    }

    It "supports DryRun without creating files" {
        $projectDir = Join-Path $TestDrive "init dry"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
        & $scriptPath -ProjectPath $projectDir -FrameworkPath $packagePath -DryRun
        @(Get-ChildItem -LiteralPath $projectDir -Force).Count | Should Be 0
    }
}
