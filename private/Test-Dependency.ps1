function Test-Dependency {
    <#
    .SYNOPSIS
        Ensures an application is installed and available in PATH.

    .DESCRIPTION
        Checks if a command is available. If missing and -DisableInstall is used,
        tries to install it via winget.

    .PARAMETER Command
        The command to test in PATH (e.g. "gsudo").

    .PARAMETER AppId
        The winget package ID used for installation if not found (e.g. "gerardog.gsudo").

    .PARAMETER DisableInstall
        If set, missing apps will be installed automatically via winget.

    .EXAMPLE
        Test-Dependency -Command "gsudo" -AppId "gerardog.gsudo"

    .EXAMPLE
        Test-Dependency -Command "restic" -AppId "restic.restic" -DisableInstall
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Command,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$AppId,

        [switch]$DisableInstall
    )

    try {
        # Check if the command is already available
        Get-Command -Name $Command -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Warning "$Command is not installed or not available in PATH."

        if ($DisableInstall) {
            throw "$Command is missing. Install it manually (winget install --id $AppId)."
        }

        Write-Verbose "Trying to install $Command via winget AppId: $AppId ..."
        Install-App $AppId
    }
}
