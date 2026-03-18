function Update-System {
    <#
    .SYNOPSIS
        Updates Windows, PowerShell modules, and installed applications.

    .DESCRIPTION
        Provides a unified update process for the system. 
        Uses gsudo to elevate where required.

    .PARAMETER Windows
        Switch to enable updating Windows updates.

    .PARAMETER PSModules
        Switch to enable updating PowerShell modules.

    .PARAMETER Apps
        Switch to enable updating applications via winget.

    .PARAMETER Python
        Switch to enable updating Python packages installed via pip.

    .PARAMETER All
        If specified, enables all update types.

    .EXAMPLE
        Update-System -Apps -PSModules

    .EXAMPLE
        Update-System -All
    #>

    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [switch]$Windows,
        [switch]$PSModules,
        [switch]$Apps,
        [switch]$Python,
        [switch]$All
    )

    # All feature switch names except -All and common parameters
    $FeatureParameters = $PSCmdlet.MyInvocation.MyCommand.Parameters.Keys |
                         Where-Object { $_ -ne 'All' -and $_ -notmatch '^(Verbose|Debug|ErrorAction|WarningAction|InformationAction|OutVariable|OutBuffer|PipelineVariable)$' }
    # If -All is used, activate all feature switches dynamically
    if ($All) {
        foreach ($param in $FeatureParameters) {
            Set-Variable -Name $param -Value $true
        }
    }
    # Determine which switches are enabled
    $EnabledFeatures = $FeatureParameters |
        Where-Object { (Get-Variable $_ -ValueOnly -ErrorAction SilentlyContinue) }
    if (-not $EnabledFeatures) {
        throw "No configuration options were selected. Use -All or specify individual switches."
    }
    
    # Ensure dependencies
    Test-Dependency -Command "gsudo" -Source "gerardog.gsudo" -App

    # Enable gsudo cache (avoids repeated elevation prompts)
    gsudo cache on | Out-Null

    # Initialize array to track updated categories
    $updatedCategories = @()

    # PowerShell Modules
    if ($PSModules -and $PSCmdlet.ShouldProcess("PowerShell modules", "Update")) {
        Write-Verbose "Updating PowerShell modules..."
        try {
            gsudo Update-Module 
            $updatedCategories += "PowerShell modules"
        } catch {
            Write-Error "Failed to update PowerShell modules: $_"
        }
    }

    # Applications via winget
    if ($Apps -and $PSCmdlet.ShouldProcess("Applications", "Update")) {
        Write-Verbose "Updating applications via winget..."
        try {
            $AllowedShortCuts = Get-ChildItem "$env:USERPROFILE\Desktop" -Filter "*.lnk" -ErrorAction SilentlyContinue |
                                Select-Object -ExpandProperty Name
            Test-Dependency -Command winget -Source Microsoft.AppInstaller -App
            Write-Verbose "Running winget upgrade in admin mode ..."
            gsudo winget upgrade --all --accept-package-agreements --accept-source-agreements `
                --disable-interactivity --include-unknown --include-pinned --silent --unknown --recurse 
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
    if ($Windows -and $PSCmdlet.ShouldProcess("Windows", "Update")) {
        Write-Verbose "Updating Windows..."
        try {
            Test-Dependency "Get-WindowsUpdate" -Module -Source PSWindowsUpdate
            $ProgressPreference = 'Continue'    # added to ensure progress bar is shown during updates
            gsudo Get-WindowsUpdate -Download -Install -AcceptAll -IgnoreReboot -ErrorAction Stop

            if (gsudo Get-WURebootStatus -Silent) {
                Write-Warning "A system reboot is required to complete the updates."
            }
            $updatedCategories += "Windows"
        } catch {
            Write-Error "Failed to update Windows: $_"
        }
    }

    # Python packages
    if ($Python -and $PSCmdlet.ShouldProcess("Python", "Update")) {
        Write-Verbose "Updating Python version..."
        try {
            Test-Dependency "pymanager" -App -Source Python.PythonInstallManager
            pymanager install 3     # always updaet to latest version
            py install --refresh
            
            $updatedCategories += "Python"
        } catch {
            Write-Error "Failed to update Python: $_"
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
