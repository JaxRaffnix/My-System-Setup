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
    # $alreadyInstalledMessages = @(
    #     "No newer package versions are available from the configured sources",
    #     "The specified application is already installed",
    #     "is already installed",
    #     "Installer failed with exit code: 29",
    #     "In den konfigurierten Quellen sind keine neueren Paketversionen verfügbar."
    # )

    try {
        # Save current desktop shortcuts before installation
        $AllowedShortCuts = Get-ChildItem "$env:USERPROFILE\Desktop" -Filter "*.lnk" -ErrorAction SilentlyContinue |
                                Select-Object -ExpandProperty Name

        # Ensure winget is available
        Test-Dependency -Command "winget" -Source "Microsoft.AppInstaller" -App

        if ($PSCmdlet.ShouldProcess($AppId, "Install application")) {
            Write-Verbose "Installing application: $AppId"

            # Execute winget installation
            winget install -e --id $AppId --silent --accept-source-agreements `
                        --accept-package-agreements --disable-interactivity 

            switch ($LASTEXITCODE) {
                0 { Write-Verbose "Application '$AppId' installed successfully." }
                29 { Write-Warning "Application '$AppId' is already installed." }
                -1978335189 {Write-Warning "Application '$AppId' is already installed." }
                -1978335212 {throw "winget can't find appid: '$AppId'."}
                default { Throw "Failed to install '$AppId'. winget exit code: $ExitCode" }
            }
        }
    }
    catch {
        Throw "An unexpected error occurred while installing '$AppId'. Error: $_"
    }
    finally {
        # Clean up desktop shortcuts, errors handled inside the function
        $DesktopPaths = @(
            "$env:USERPROFILE\Desktop",
            "$env:PUBLIC\Desktop"
        )
        Remove-UnwantedShortcuts -Paths $DesktopPaths -AllowedShortcuts $AllowedShortcuts
    }
}
