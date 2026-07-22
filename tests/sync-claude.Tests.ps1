Describe "sync-claude.ps1" {

    $scriptPath = Join-Path $PSScriptRoot "..\scripts\sync-claude.ps1"

    BeforeAll {
        $frameworkPath = Join-Path $PSScriptRoot "fixtures\mock-framework"
    }

    It "Copia agents de framework/ para .claude/agents/" {
        $projectDir = Join-Path $TestDrive "test-sync-agents"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        $dest = Join-Path $projectDir ".claude\agents\sda-test-agent.md"
        Test-Path $dest | Should Be $true
        (Get-Content $dest -Raw) | Should Match "sda-test-agent"
    }

    It "Copia rules de framework/ para .claude/rules/" {
        $projectDir = Join-Path $TestDrive "test-sync-rules"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        $dest = Join-Path $projectDir ".claude\rules\sda-test-rule.md"
        Test-Path $dest | Should Be $true
        (Get-Content $dest -Raw) | Should Match "Regra de teste"
    }

    It "Copia skills (diretorios) recursivamente" {
        $projectDir = Join-Path $TestDrive "test-sync-skills"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        $skillFile = Join-Path $projectDir ".claude\skills\sda-test-skill\SKILL.md"
        Test-Path $skillFile | Should Be $true
        (Get-Content $skillFile -Raw) | Should Match "Skill de teste"
    }

    It "Preserva override local (prefixo != sda-)" {
        $projectDir = Join-Path $TestDrive "test-sync-preserve"
        $agentsDir = Join-Path $projectDir ".claude\rules"
        New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null
        "override local" | Out-File (Join-Path $agentsDir "my-project-rule.md") -Encoding UTF8

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        $localFile = Join-Path $projectDir ".claude\rules\my-project-rule.md"
        (Get-Content $localFile -Raw) | Should Match "override local"
    }

    It "Sobrescreve sda-* quando ja existe" {
        $projectDir = Join-Path $TestDrive "test-sync-overwrite"
        $agentsDir = Join-Path $projectDir ".claude\agents"
        New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null
        "versao antiga" | Out-File (Join-Path $agentsDir "sda-test-agent.md") -Encoding UTF8

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        $dest = Join-Path $projectDir ".claude\agents\sda-test-agent.md"
        (Get-Content $dest -Raw) | Should Match "sda-test-agent"
        (Get-Content $dest -Raw) | Should Not Match "versao antiga"
    }

    It "Force=true sobrescreve tudo" {
        $projectDir = Join-Path $TestDrive "test-sync-force"
        $agentsDir = Join-Path $projectDir ".claude\rules"
        New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null
        "override local" | Out-File (Join-Path $agentsDir "my-project-rule.md") -Encoding UTF8

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath -Force

        $localFile = Join-Path $projectDir ".claude\rules\my-project-rule.md"
        Test-Path $localFile | Should Be $true
    }

    It "Cria .claude/ se nao existe" {
        $projectDir = Join-Path $TestDrive "test-sync-create"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $frameworkPath

        Test-Path (Join-Path $projectDir ".claude") | Should Be $true
        Test-Path (Join-Path $projectDir ".claude\agents") | Should Be $true
        Test-Path (Join-Path $projectDir ".claude\rules") | Should Be $true
        Test-Path (Join-Path $projectDir ".claude\skills") | Should Be $true
    }

    It "Erro claro se framework nao existe" {
        $badPath = Join-Path $TestDrive "nao-existe"
        { & $scriptPath -ProjectPath $TestDrive -FrameworkPath $badPath } | Should Throw
    }

    It "Copia sda-qa-validator/ com subdiretorios" {
        $fwWithModules = Join-Path $TestDrive "mock-fw-modules"
        $srcSkills = Join-Path $fwWithModules "skills\sda-test-skill"
        New-Item -ItemType Directory -Path $srcSkills -Force | Out-Null
        "# SKILL.md" | Out-File (Join-Path $srcSkills "SKILL.md") -Encoding UTF8
        New-Item -ItemType Directory -Path (Join-Path $srcSkills "assets") -Force | Out-Null
        "template" | Out-File (Join-Path $srcSkills "assets\template.md") -Encoding UTF8

        $projectDir = Join-Path $TestDrive "test-sync-modules"
        New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

        & $scriptPath -ProjectPath $projectDir -FrameworkPath $fwWithModules

        $asset = Join-Path $projectDir ".claude\skills\sda-test-skill\assets\template.md"
        Test-Path $asset | Should Be $true
    }
}
