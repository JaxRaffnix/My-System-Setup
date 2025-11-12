function Invoke-Diagnostics {
    <#
    .SYNOPSIS
    Runs a suite of system and storage diagnostics.

    .DESCRIPTION
    Executes system health, storage, and cleanup scripts located in a diagnostics folder.
    Each category (System, Storage, Cleanup) corresponds to a separate script file.

    .PARAMETER System
    Runs system diagnostics (system.ps1).

    .PARAMETER Storage
    Runs storage diagnostics (storage.ps1).

    .PARAMETER Cleanup
    Runs cleanup tasks (cleanup.ps1).

    .PARAMETER All
    Runs all categories.

    .PARAMETER ConfigPath
    Path to the diagnostics folder containing the scripts.

    .PARAMETER ReportFile
    Path to save the output report.
    #>

    [CmdletBinding()]
    param (
        [switch]$System,
        [switch]$Storage,
        [switch]$Cleanup,
        [switch]$All,

        [string]$ConfigPath = "$PSScriptRoot/../scripts/diagnostics/",
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

    $categories = @{}
    if ($System)  { $categories['System']  = 'system.ps1' }
    if ($Storage) { $categories['Storage'] = 'storage.ps1' }
    if ($Cleanup) { $categories['Cleanup'] = 'cleanup.ps1' }

    Write-Verbose "Running diagnostic categories: $($categories -join ', ')" 
    
    foreach ($category in $categories.Keys) {
        Add-Content -Path $ReportFile -Value "`n===== $category =====`n"
        Write-Host "`n=== Running $category ===" -ForegroundColor Cyan

        $scriptPath = Join-Path $ConfigPath $categories[$category]
        if (-not (Test-Path $scriptPath)) {
            Add-Content -Path $ReportFile -Value "[$category] script not found: $scriptPath"
            Write-Error "[$category] script not found: $scriptPath"
            continue
        }

        try {
            $result = & $scriptPath 2>&1 | Tee-Object -Variable result
            Add-Content -Path $ReportFile -Value $result
        } catch {
            Add-Content -Path $ReportFile -Value "[$category] failed: $($_.Exception.Message)"
            Write-Error "[$category] failed: $($_.Exception.Message)"
        }
    }

    Write-Host "Successfully run diagnostics and saved report to '$ReportFile'." -ForegroundColor Green
}
