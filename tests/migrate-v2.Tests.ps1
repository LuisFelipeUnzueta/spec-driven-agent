Describe "migrate-v2.ps1" {
    $scriptPath = Join-Path $PSScriptRoot "..\scripts\migrate-v2.ps1"

    function New-TaskFile {
        param([string]$Project, [string]$Name, [string]$Content)
        $tasks = Join-Path $Project "docs\specs\features\sample\v1\tasks"
        New-Item -ItemType Directory -Path $tasks -Force | Out-Null
        $path = Join-Path $tasks $Name
        [IO.File]::WriteAllText($path, $Content, (New-Object Text.UTF8Encoding($false)))
        return $path
    }

    It "maps gates none to validation none" {
        $project = Join-Path $TestDrive "migrate-none"
        $task = New-TaskFile $project "T1.md" "risk: low`ngates: none`n"
        & $scriptPath -ProjectPath $project
        [IO.File]::ReadAllText($task) | Should Match '(?m)^validation: none\r?$'
    }

    It "maps qa and preserves bold field style" {
        $project = Join-Path $TestDrive "migrate-qa"
        $task = New-TaskFile $project "T1.md" "- **risk**: medium`n- **gates**: [qa]`n"
        & $scriptPath -ProjectPath $project
        [IO.File]::ReadAllText($task) | Should Match '(?m)^- \*\*validation\*\*: qa\r?$'
    }

    It "maps full and removes model fields" {
        $project = Join-Path $TestDrive "migrate-full"
        $task = New-TaskFile $project "T1.md" "risk: high`ngates: [qa, tech_review]`nmodel: opus`nreasoning_effort: xhigh`n"
        & $scriptPath -ProjectPath $project
        $content = [IO.File]::ReadAllText($task)
        $content | Should Match '(?m)^validation: full\r?$'
        $content | Should Not Match '(?m)^(model|reasoning_effort):'
    }

    It "aborts atomically for invalid input" {
        $project = Join-Path $TestDrive "migrate-invalid"
        $valid = New-TaskFile $project "T1.md" "risk: low`ngates: [qa]`n"
        $invalid = New-TaskFile $project "T2.md" "risk: low`ngates: [security]`n"
        $before = [IO.File]::ReadAllText($valid)
        $didThrow = $false
        try { & $scriptPath -ProjectPath $project } catch { $didThrow = $true }
        $didThrow | Should Be $true
        [IO.File]::ReadAllText($valid) | Should Be $before
        [IO.File]::ReadAllText($invalid) | Should Match 'gates:'
    }

    It "rejects a migrated task without risk" {
        $project = Join-Path $TestDrive "migrate-no-risk"
        New-TaskFile $project "T1.md" "gates: [qa]`n" | Out-Null
        $didThrow = $false
        try { & $scriptPath -ProjectPath $project } catch { $didThrow = $true }
        $didThrow | Should Be $true
    }

    It "does not write during DryRun" {
        $project = Join-Path $TestDrive "migrate-dry"
        $task = New-TaskFile $project "T1.md" "risk: low`ngates: [qa]`n"
        $before = [IO.File]::ReadAllText($task)
        & $scriptPath -ProjectPath $project -DryRun
        [IO.File]::ReadAllText($task) | Should Be $before
    }
}
