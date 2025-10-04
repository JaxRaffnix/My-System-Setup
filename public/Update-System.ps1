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

    .PARAMETER UpdatePip
        Switch to enable updating Python packages installed via pip.

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
        [switch]$UpdatePip,
        [switch]$All
    )

    # Handle -All flag
    if ($All) {
        $UpdateWindows   = $true
        $UpdatePSModules = $true
        $UpdateApps      = $true
        $UpdatePip       = $true
    }

    # Ensure dependencies
    Test-Dependency -Command "gsudo" -Source "gerardog.gsudo" -App

    # Enable gsudo cache (avoids repeated elevation prompts)
    gsudo cache on | Out-Null

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
            $AllowedShortCuts = Get-ChildItem "$env:USERPROFILE\Desktop" -Filter "*.lnk" -ErrorAction SilentlyContinue |
                                Select-Object -ExpandProperty Name
            Test-Dependency -Command winget -Source Microsoft.AppInstaller -App
            gsudo winget upgrade --all --accept-package-agreements --accept-source-agreements `
                --disable-interactivity --include-unknown --include-pinned --silent --force
        } catch {
            Write-Error "Failed to update applications via winget: $_"
        } finally {
            Remove-DesktopShortcuts -OldShortCuts $AllowedShortCuts   
        }
    }
         

    # Windows Updates
    if ($UpdateWindows -and $PSCmdlet.ShouldProcess("Windows", "Update")) {
        Write-Verbose "Updating Windows..."
        try {
            Test-Dependency PSWindowsUpdate -Module
            gsudo Get-WindowsUpdate -Download -Install -AcceptAll -ErrorAction Stop

            if ((gsudo Get-WURebootStatus).RebootRequired) {
                Write-Warning "A system reboot is required to complete the updates."
            }
        } catch {
            Write-Error "Failed to update Windows: $_"
        }
    }

    if ($UpdatePip -and $PSCmdlet.ShouldProcess("Python packages", "Update")) {
        Write-Verbose "Updating Python packages via pip..."
        try {
            Test-Dependency pip -App -Source Python.Python.3.13  

            python.exe -m pip install --upgrade pip

            $packages = & pip list --outdated --format=freeze | ForEach-Object {
                $_.Split('==')[0]
            }

            foreach ($package in $packages) {
                Write-Verbose "Updating package: $package"
                & pip install --upgrade $package
            }
        } catch {
            Write-Error "Failed to update Python packages via pip: $_"
        }
    }
    Write-Verbose "System update process finished."
}
