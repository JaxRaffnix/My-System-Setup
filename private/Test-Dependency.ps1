function Test-Dependency {
    <#
    .SYNOPSIS
        Ensures an application or module is installed and available.

    .DESCRIPTION
        Verifies whether a given command is available in the current session.
        If not, tries to install it via winget (for apps) or PowerShell Gallery (for modules),
        unless -DisableInstall is set.

    .PARAMETER Command
        The command to test in PATH or session (e.g. "gsudo" or "Get-WindowsUpdate").

    .PARAMETER Source
        The installation identifier:
          - For -App: winget AppId (e.g. "gerardog.gsudo")
          - For -Module: PowerShell module name (e.g. "PSWindowsUpdate")

    .PARAMETER App
        Indicates that the dependency is a winget application.

    .PARAMETER Module
        Indicates that the dependency is a PowerShell module.

    .PARAMETER DisableInstall
        If set, missing dependencies will not be installed automatically.

    .EXAMPLE
        Test-Dependency -Command "gsudo" -App -Source "gerardog.gsudo"

    .EXAMPLE
        Test-Dependency -Command "Get-WindowsUpdate" -Module -Source "PSWindowsUpdate"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Command,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Source,

        [switch]$App,
        [switch]$Module,
        [switch]$DisableInstall
    )

    try {
        # Check if the command is already available
        Get-Command -Name $Command -ErrorAction Stop | Out-Null
        Write-Verbose "$Command is already available."
    }
    catch {
        Write-Warning "$Command is not installed or not available."

        if ($DisableInstall) {
            throw "Automatic install for $Command is disabled. Install it manually."
        }

        if ($App) {
            Write-Verbose "Trying to install $Command via winget AppId: $Source ..."
            Install-App -Id $Source
        }
        elseif ($Module) {
            Write-Verbose "Trying to install PowerShell module: $Source ..."
            Install-PSModule -Name $Source
        }
        else {
            throw "Specify either -App or -Module for $Command."
        }

        # Final verification
        try {
            Get-Command -Name $Command -ErrorAction Stop | Out-Null
            Write-Verbose "Dependency '$Command' installed successfully."
        }
        catch {
            throw "Dependency '$Command' could not be validated after installation."
        }
    }
}
