function Install-PSModule {
    <#
    .SYNOPSIS
        Installs and imports a PowerShell module.

    .DESCRIPTION
        Ensures required tools (e.g. gsudo) are available, installs the specified PowerShell module,
        and imports it into the current session.

    .PARAMETER ModuleName
        The name of the PowerShell module to install and import.

    .EXAMPLE
        Install-PSModule -ModuleName "PSWindowsUpdate"
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName
    )

    # Ensure required tools are available
    Test-Dependency -Command "gsudo" -Source "gerardog.gsudo" -App

    if ($PSCmdlet.ShouldProcess($ModuleName, "Install PowerShell module")) {
        try {
            Write-Verbose "Installing PowerShell module: $ModuleName"

            Install-Module -Name $ModuleName -Force -Scope CurrentUser -AllowClobber -ErrorAction Stop
            Import-Module -Name $ModuleName -Force -Scope Local -ErrorAction Stop

            Write-Verbose "Module '$ModuleName' installed and imported successfully."
        }
        catch {
            throw "Failed to install or import PowerShell module '$ModuleName'. Error: $_"
        }
    }
}
