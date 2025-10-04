function Install-App {
    <#
    .SYNOPSIS
        Installs an application via winget.

    .DESCRIPTION
        Ensures winget is available, installs the application specified by AppId,
        and cleans up desktop shortcuts after installation.

    .PARAMETER AppId
        The winget package identifier of the application to install.

    .EXAMPLE
        Install-App -AppId "gerardog.gsudo"
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$AppId
    )

    # Messages indicating app is already installed
    $alreadyInstalledMessages = @(
        "No newer package versions are available from the configured sources",
        "The specified application is already installed",
        "is already installed",
        "Installer failed with exit code: 29"
    )

    try {
        # Save current desktop shortcuts before installation
        $AllowedShortCuts = Get-ChildItem "$env:USERPROFILE\Desktop" -Filter "*.lnk" -ErrorAction SilentlyContinue |
                                Select-Object -ExpandProperty Name

        # Ensure winget is available
        Test-Dependency -Command "winget" -Source "Microsoft.AppInstaller" -App

        if ($PSCmdlet.ShouldProcess($AppId, "Install application")) {
            Write-Verbose "Installing application: $AppId"

            # Execute winget installation
            $Result = winget install -e --id $AppId --silent --accept-source-agreements `
                        --accept-package-agreements --disable-interactivity --force 2>&1

            # Check output for already installed messages
            if ($alreadyInstalledMessages | Where-Object { $Result -match $_ }) {
                Write-Warning "The application '$AppId' is already installed."
            }
            elseif ($Result -match "Successfully installed") {
                Write-Verbose "Successfully installed '$AppId'."
            }
            else {
                Write-Error "Failed to install '$AppId'. Output: $Result"
            }
        }
    }
    catch {
        Write-Error "An unexpected error occurred while installing '$AppId'. Error: $_"
    }
    finally {
        # Clean up desktop shortcuts, errors handled inside the function
        Remove-DesktopShortcuts -OldShortCuts $AllowedShortCuts
    }
}
