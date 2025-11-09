function Invoke-Diagnostics {
    <#
    .SYNOPSIS
    Runs a suite of system and storage diagnostics.

    .DESCRIPTION
    Executes system health and storage checks as defined in an external YAML file.
    The YAML file references external PowerShell script files, which are executed independently.

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
        [string]$ConfigPath = "$PSScriptRoot/../config/diagnostics/",
        [string]$ReportFile = "$env:USERPROFILE\Documents\$(Get-Date -Format 'yyyyMMdd_HHmm')_SystemDiagnostics.txt"
    )

    # Expand group switches
    if ($All) {
        $System = $true
        $Storage = $true
        $Cleanup = $true
    }

    if (-not ($System -or $Storage -or $Cleanup)) {
        throw "No diagnostic category selected. Use -System, -Storage, -Cleanup or -All."
    }
    if (-not (Test-Path $ConfigPath)) {
        throw "Diagnostics configuration folder not found: $ConfigPath"
    }

    # Prerequisite checks
    Test-Dependency -Command "gsudo" -Source "gerardog.gsudo" -App
    gsudo cache on | Out-Null
    Test-Dependency "Get-WindowsUpdate" -Module -Source "PSWindowsUpdate"

    try {
        Test-Dependency -Command "ConvertFrom-Yaml" -Module -Source "powershell-yaml"    
        $rawYaml = Get-Content -Path Join-Path $ConfigPath "diagnostics.yaml" -Raw -ErrorAction Stop
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
    
    foreach ($category in $selected) {
        Add-Content -Path $ReportFile -Value "`n===== $category =====`n"
        foreach ($item in $checks.$category) {
            Add-Content -Path $ReportFile -Value "`n--- $($item.Title) ---`n"
            Write-Host "`n=== $($item.Title) ===" -ForegroundColor Cyan
            try {
                $scriptPath = Join-Path $ConfigPath $item.Script
                if (-not (Test-Path $scriptPath)) {
                    throw "Script file not found: $scriptPath"
                }
                $result = & $scriptPath 2>&1 | Tee-Object -Variable result
                Add-Content -Path $ReportFile -Value $result
            } catch {
                Add-Content -Path $ReportFile -Value "[$($item.Title)] failed: $($_.Exception.Message)"
                Write-Error "[$($item.Title)] failed: $($_.Exception.Message)"
            }
        }
    }
    Write-Host "Successfully run diagnostics and saved report to '$ReportFile'." -ForegroundColor Green
}
