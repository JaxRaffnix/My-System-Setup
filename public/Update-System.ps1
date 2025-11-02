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

    # Initialize array to track updated categories
    $updatedCategories = @()

    # PowerShell Modules
    if ($UpdatePSModules -and $PSCmdlet.ShouldProcess("PowerShell modules", "Update")) {
        Write-Verbose "Updating PowerShell modules..."
        try {
            gsudo Update-Module 
            $updatedCategories += "PowerShell modules"
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
            Write-Verbose "Running winget upgrade in admin mode ..."
            gsudo winget upgrade --all --accept-package-agreements --accept-source-agreements `
                --disable-interactivity --include-unknown --include-pinned --silent 
            Write-Verbose "Running winget upgrade in user mode ..."
            winget upgrade --all --accept-package-agreements --accept-source-agreements `
                --disable-interactivity --include-unknown --include-pinned --silent 
            $updatedCategories += "Winget applications"
        } catch {
            Write-Error "Failed to update applications via winget: $_"
        } finally {
            $DesktopPaths = @(
                "$env:USERPROFILE\Desktop",
                "$env:PUBLIC\Desktop"
            )
            Remove-UnwantedShortcuts -Paths $DesktopPaths -AllowedShortcuts $AllowedShortcuts
        }
    }

    # Windows Updates
    if ($UpdateWindows -and $PSCmdlet.ShouldProcess("Windows", "Update")) {
        Write-Verbose "Updating Windows..."
        try {
            Test-Dependency "Get-WindowsUpdate" -Module -Source PSWindowsUpdate
            gsudo Get-WindowsUpdate -Download -Install -AcceptAll -IgnoreReboot -ErrorAction Stop 2>&1 | Out-Host

            if ((gsudo Get-WURebootStatus).RebootRequired) {
                Write-Warning "A system reboot is required to complete the updates."
            }
            $updatedCategories += "Windows"
        } catch {
            Write-Error "Failed to update Windows: $_"
        }
    }

    # Python packages
    if ($UpdatePip -and $PSCmdlet.ShouldProcess("Python packages", "Update")) {
        Write-Verbose "Updating Python packages via pip..."
        try {
            Test-Dependency pip -App -Source Python.Python.3.13  
            python.exe -m pip install --upgrade pip

            $packagesJson = & pip list --outdated --format=json | ConvertFrom-Json
            $packages = $packagesJson | ForEach-Object { $_.name }

            foreach ($package in $packages) {
                Write-Verbose "Updating package: $package"
                & pip install --upgrade $package
            }
            $updatedCategories += "Python packages"
        } catch {
            Write-Error "Failed to update Python packages via pip: $_"
        }
    }

    # Final message
    if ($updatedCategories.Count -gt 0) {
        $categoriesString = $updatedCategories -join ", "
        Write-Host "Successfully updated system: $categoriesString." -ForegroundColor Green
    } else {
        Write-Warning "No update categories were executed."
    }

}
