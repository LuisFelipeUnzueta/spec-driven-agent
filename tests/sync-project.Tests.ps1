Describe "sync-project.ps1" {
    $scriptPath = Join-Path $PSScriptRoot "..\scripts\sync-project.ps1"
    $frameworkPath = Join-Path $PSScriptRoot "fixtures\mock-package\framework"

    It "projects Codex-native skills and TOML agents" {
        $projectDir = Join-Path $TestDrive "codex-project"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath -Host Codex

        Test-Path (Join-Path $projectDir ".agents\skills\sda-test-skill\SKILL.md") | Should Be $true
        Test-Path (Join-Path $projectDir ".codex\agents\sda-test-reviewer.toml") | Should Be $true
        Test-Path (Join-Path $projectDir ".claude") | Should Be $false
        $toml = [IO.File]::ReadAllText((Join-Path $projectDir ".codex\agents\sda-test-reviewer.toml"))
        $toml | Should Match '^name = "sda-test-reviewer"'
        $toml | Should Match '(?m)^model = "gpt-test"\r?$'
        $toml | Should Match '(?m)^model_reasoning_effort = "high"\r?$'
        $toml | Should Match '(?m)^developer_instructions = "'
    }

    It "projects Claude skills, agents and project rules" {
        $projectDir = Join-Path $TestDrive "claude-project"
        $ruleDir = Join-Path $projectDir ".agents\rules"
        New-Item -ItemType Directory -Path $ruleDir -Force | Out-Null
        [IO.File]::WriteAllText((Join-Path $ruleDir "project-rule.md"), "project rule", (New-Object Text.UTF8Encoding($false)))

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath -Host Claude

        Test-Path (Join-Path $projectDir ".claude\skills\sda-test-skill\SKILL.md") | Should Be $true
        Test-Path (Join-Path $projectDir ".claude\agents\sda-test-reviewer.md") | Should Be $true
        Test-Path (Join-Path $projectDir ".claude\rules\project-rule.md") | Should Be $true
        Test-Path (Join-Path $projectDir ".codex") | Should Be $false
        $agent = [IO.File]::ReadAllText((Join-Path $projectDir ".claude\agents\sda-test-reviewer.md"))
        $agent | Should Match '(?m)^model: sonnet\r?$'
        $agent | Should Match '(?m)^effort: high\r?$'
    }

    It "projects Both, custom skills and excludes DS_Store" {
        $projectDir = Join-Path $TestDrive "both project with spaces"
        $customDir = Join-Path $projectDir ".agents\skills\project-helper"
        New-Item -ItemType Directory -Path $customDir -Force | Out-Null
        [IO.File]::WriteAllText((Join-Path $customDir "SKILL.md"), "---`nname: project-helper`ndescription: Local helper.`n---`n", (New-Object Text.UTF8Encoding($false)))

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath -Host Both

        Test-Path (Join-Path $projectDir ".codex\agents\sda-test-reviewer.toml") | Should Be $true
        Test-Path (Join-Path $projectDir ".claude\agents\sda-test-reviewer.md") | Should Be $true
        Test-Path (Join-Path $projectDir ".claude\skills\project-helper\SKILL.md") | Should Be $true
        @(Get-ChildItem -LiteralPath $projectDir -Recurse -Force -File -Filter ".DS_Store").Count | Should Be 0
        Test-Path (Join-Path $projectDir ".agents\.sda-manifest.json") | Should Be $true
    }

    It "is idempotent and preserves content outside managed blocks" {
        $projectDir = Join-Path $TestDrive "managed-content"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
        [IO.File]::WriteAllText((Join-Path $projectDir "AGENTS.md"), "# Team rules`n`nKeep this.`n", (New-Object Text.UTF8Encoding($false)))
        [IO.File]::WriteAllText((Join-Path $projectDir "CLAUDE.md"), "# Claude custom`n", (New-Object Text.UTF8Encoding($false)))

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath -Host Both
        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath -Host Both

        $agents = [IO.File]::ReadAllText((Join-Path $projectDir "AGENTS.md"))
        $claude = [IO.File]::ReadAllText((Join-Path $projectDir "CLAUDE.md"))
        $agents | Should Match 'Keep this\.'
        $claude | Should Match '# Claude custom'
        ([regex]::Matches($agents, '<!-- sda:start -->').Count) | Should Be 1
        ([regex]::Matches($claude, '<!-- sda:start -->').Count) | Should Be 1
    }

    It "cleans only previously managed files when changing host" {
        $projectDir = Join-Path $TestDrive "host-change"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath -Host Both
        Add-Content -LiteralPath (Join-Path $projectDir "CLAUDE.md") -Value "# Keep Claude note"
        $externalDir = Join-Path $projectDir ".claude\agents"
        [IO.File]::WriteAllText((Join-Path $externalDir "external.md"), "external", (New-Object Text.UTF8Encoding($false)))

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath -Host Codex

        Test-Path (Join-Path $projectDir ".claude\agents\sda-test-reviewer.md") | Should Be $false
        Test-Path (Join-Path $projectDir ".claude\agents\external.md") | Should Be $true
        $claude = [IO.File]::ReadAllText((Join-Path $projectDir "CLAUDE.md"))
        $claude | Should Match 'Keep Claude note'
        $claude | Should Not Match '<!-- sda:start -->'
    }

    It "does not write during DryRun" {
        $projectDir = Join-Path $TestDrive "dry-run"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath -Host Both -DryRun

        @(Get-ChildItem -LiteralPath $projectDir -Force).Count | Should Be 0
    }

    It "throws for an invalid framework" {
        $projectDir = Join-Path $TestDrive "bad-framework-project"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null
        $didThrow = $false
        try { & $scriptPath -ProjectPath $projectDir -FrameworkPath (Join-Path $TestDrive "missing") } catch { $didThrow = $true }
        $didThrow | Should Be $true
    }
}
