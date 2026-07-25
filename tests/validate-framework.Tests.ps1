Describe "validate-framework.ps1" {
    It "accepts the v2 framework" {
        $scriptPath = Join-Path $PSScriptRoot "..\scripts\validate-framework.ps1"
        { & $scriptPath } | Should Not Throw
    }
}
