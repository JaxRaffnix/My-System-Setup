function Remove-UnwantedShortcuts {
    <#
    .SYNOPSIS
        Removes broken or unwanted shortcuts from specified directories.

    .DESCRIPTION
        Iterates through one or more directories and:
        - Removes shortcuts whose target paths are invalid (if -RemoveBroken)
        - Removes shortcuts not listed in the allowed list (if -AllowedShortcuts provided)
        Supports dry-run and elevation.

    .PARAMETER Paths
        One or more directories to scan for shortcuts.

    .PARAMETER AllowedShortcuts
        An array of shortcut filenames to keep. If provided, all others are removed.

    .PARAMETER RemoveBroken
        If set, removes shortcuts whose target paths no longer exist.

    .PARAMETER DryRun
        If set, simulates the deletions without actually removing files.
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Paths,

        [string[]]$AllowedShortcuts,

        [switch]$RemoveBroken,

        [switch]$DryRun
    )

    Test-Dependency -Command "gsudo" -Source "gerardog.gsudo" -App

    gsudo cache on | Out-Null

    foreach ($Path in $Paths) {
        if (-not (Test-Path $Path)) {
            Throw "The path '$Path' does not exist. Skipping..."
        }

        Write-Verbose "Scanning '$Path' for shortcuts..."

        $Shortcuts = Get-ChildItem -Path $Path -Filter "*.lnk" -Recurse -ErrorAction SilentlyContinue

        foreach ($Shortcut in $Shortcuts) {
            $shell = New-Object -ComObject WScript.Shell
            $target = $shell.CreateShortcut($Shortcut.FullName).TargetPath
            $shouldRemove = $false

            # Case 1: Remove if target is broken 
            if ($RemoveBroken) {    # only if they point to a real filesystem path
                if (-not [string]::IsNullOrEmpty($target) -and $target -match '^[a-zA-Z]:\\' -and (-not (Test-Path $target))) {
                    $shouldRemove = $true
                }
            }

            # Case 2: Remove if not in allowed list
            if ($AllowedShortcuts -and ($AllowedShortcuts -notcontains $Shortcut.Name)) {
                $shouldRemove = $true
            }

            if ($shouldRemove -and $PSCmdlet.ShouldProcess($Shortcut.FullName, "Remove shortcut")) {
                if ($DryRun) {
                    Write-Host "[DryRun] Would remove: $($Shortcut.FullName)"
                } else {
                    try {
                        gsudo Remove-Item $Shortcut.FullName -Force -ErrorAction Stop
                        Write-Host "Removed shortcut: $($Shortcut.FullName)"
                    } catch {
                        Write-Error "Failed to remove shortcut '$($Shortcut.Name)': $_"
                    }
                }
            }
        }
    }

    Write-Host "Finished processing all provided paths: $paths." -ForegroundColor Green
}
