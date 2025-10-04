function Update-System {
    <#
    .SYNOPSIS
        Updates Windows, PowerShell modules, and installed applications.

    .DESCRIPTION
        Provides a unified update process for the system. 
        Uses gsudo to elevate where required.

    .PARAMETER UpdateWindows
        Switch to enable updating Windows updates.

    .PARAMETER UpdatePSModules
        Switch to enable updating PowerShell modules.

    .PARAMETER UpdateApps
        Switch to enable updating applications via winget.

    .PARAMETER All
        If specified, enables all update types.

    .EXAMPLE
        Update-System -UpdateApps -UpdatePSModules

    .EXAMPLE
        Update-System -All
    #>

    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [switch]$UpdateWindows,
        [switch]$UpdatePSModules,
        [switch]$UpdateApps,
        [switch]$All
    )

    try {
        # Ensure dependencies
        Test-Dependency -Command "gsudo" -AppId "gerardog.gsudo"
        Test-Dependency -Command "winget" -AppId "Microsoft.Winget.Source"

        # Enable gsudo cache (avoids repeated elevation prompts)
        gsudo cache on | Out-Null

        # Collect allowed shortcuts (before updates may add new ones)
        $AllowedShortCuts = Get-ChildItem "$env:USERPROFILE\Desktop" -Filter "*.lnk" -ErrorAction SilentlyContinue |
                            Select-Object -ExpandProperty Name

        # Handle -All flag
        if ($All) {
            $UpdateWindows   = $true
            $UpdatePSModules = $true
            $UpdateApps      = $true
        }

        # PowerShell Modules
        if ($UpdatePSModules -and $PSCmdlet.ShouldProcess("PowerShell modules", "Update")) {
            Write-Verbose "Updating PowerShell modules..."
            try {
                gsudo Update-Module -Force
            } catch {
                Write-Error "Failed to update PowerShell modules: $_"
            }
        }

        # Applications via winget
        if ($UpdateApps -and $PSCmdlet.ShouldProcess("Applications", "Update")) {
            Write-Verbose "Updating applications via winget..."
            try {
                gsudo winget upgrade --all --accept-package-agreements --accept-source-agreements `
                    --disable-interactivity --include-unknown --include-pinned --silent --force
            } catch {
                Write-Error "Failed to update applications via winget: $_"
            }
        }

        # Remove unwanted desktop shortcuts (after updates may add them back)
        try {
            Remove-MSSAppShortcuts -OldShortCuts $AllowedShortCuts
        } catch {
            Write-Warning "Failed to clean up desktop shortcuts: $_"
        }

        # Windows Updates
        if ($UpdateWindows -and $PSCmdlet.ShouldProcess("Windows", "Update")) {
            Write-Verbose "Updating Windows..."
            try {
                gsudo Get-WindowsUpdate -Download -Install -AcceptAll -ErrorAction Stop

                if ((gsudo Get-WURebootStatus).RebootRequired) {
                    Write-Warning "A system reboot is required to complete the updates."
                }
            } catch {
                Write-Error "Failed to update Windows: $_"
            }
        }
    }
    catch {
        Write-Error "Update-System failed: $_"
    }
    finally {
        Write-Verbose "System update process finished."
    }
}
