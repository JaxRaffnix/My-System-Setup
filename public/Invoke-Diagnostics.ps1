function Invoke-Diagnostics {
    <#
    .SYNOPSIS
    Runs a suite of system and storage diagnostics.

    .DESCRIPTION
    Executes system health and storage checks as defined in an external YAML file.

    .PARAMETER System
    Runs Windows Defender, reliability, DISM, SFC, CHKDSK, and update checks.

    .PARAMETER Storage
    Runs disk health, space usage, and large-file analysis.

    .PARAMETER Cleanup
    Performs cleanup tasks (delegates to Invoke-SystemCleanup).

    .PARAMETER All
    Runs all categories (System, Storage, and Cleanup).

    .EXAMPLE
    Invoke-Diagnostics -System -Storage
    #>

    [CmdletBinding()]
    param (
        [switch]$System,
        [switch]$Storage,
        [switch]$Cleanup,
        [switch]$All,

        [Parameter(Mandatory=$false)]
        [string]$ConfigPath = "$PSScriptRoot/../config/system_diagnostics.yaml"
    )

    # Expand group switches
    if ($All) {
        $System = $true
        $Storage = $true
        $Cleanup = true
    }

    if (-not ($System -or $Storage -or $Cleanup)) {
        throw "No diagnostic category selected. Use -System, -Storage, -Cleanup or -All."
    }
    if (-not (Test-Path $ConfigPath)) {
        throw "Diagnostics configuration file not found: $ConfigPath"
    }

    # Prerequisite checks
    Test-Dependency -Command "gsudo" -Source "gerardog.gsudo" -App
    Test-Dependency "Get-WindowsUpdate" -Module -Source "PSWindowsUpdate"

    try {
        Test-Dependency -Command "ConvertFrom-Yaml" -Module -Source "powershell-yaml"    
        $rawYaml = Get-Content -Path $ConfigPath -Raw -ErrorAction Stop
        $checks = $rawYaml | ConvertFrom-Yaml
    }
    catch {
        throw "Failed to load diagnostics YAML: $_"
    }

    $selected = @()
    if ($System)  { $selected += 'System' }
    if ($Storage) { $selected += 'Storage' }
    if ($Cleanup) {$selected += 'Cleanup'}

    Write-Verbose "Running diagnostic categories: $($selected -join ', ')" 
    gsudo cache on | Out-Null

    foreach ($category in $selected) {
        foreach ($item in $checks.$category) {
            Write-Host "`n=== $($item.Title) ===" -ForegroundColor Cyan
            try {
                Invoke-Expression $item.Command
            } catch {
                Write-Error "[$($item.Title)] failed: $($_.Exception.Message)"
            }
        }
    }

    Write-Verbose "Diagnostics completed." 
}
