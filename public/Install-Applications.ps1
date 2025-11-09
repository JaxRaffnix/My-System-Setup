function Install-Applications {
<#
.SYNOPSIS
    Install application categories and PowerShell modules defined in a YAML configuration.

.DESCRIPTION
    Install-Applications reads an applications YAML configuration (default: ../config/applications.yaml)
    and installs items in one or more categories. Categories can contain PowerShell modules
    and 'winget' application IDs. The cmdlet uses helper functions `Install-PSModule` and
    `Install-App` for installing modules and winget apps respectively. It also ensures
    `gsudo` is available and enables its cache.

    This function supports WhatIf/Confirm through SupportsShouldProcess on module and app installs.

.PARAMETER All
    Switch. Install all categories from the configuration.

.PARAMETER Init
    Switch. Install the 'Init' category.

.PARAMETER Core
    Switch. Install the 'Core' category.

.PARAMETER Messengers
    Switch. Install the 'Messengers' category.

.PARAMETER ProgrammingTools
    Switch. Install the 'ProgrammingTools' category.

.PARAMETER Games
    Switch. Install the 'Games' category.

.PARAMETER ConfigPath
    Path to the applications YAML configuration file. Defaults to "$PSScriptRoot/../config/applications.yaml".

.EXAMPLE
    Install-Applications -All

.EXAMPLE
    Install-Applications -Core -ProgrammingTools -ConfigPath 'C:\configs\apps.yaml'
#>

    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [switch]$All,
        [switch]$Init,
        [switch]$Core,
        [switch]$Messengers,
        [switch]$ProgrammingTools,
        [switch]$Games,

        [Parameter(Mandatory=$false)]
        [string]$ConfigPath = "$PSScriptRoot/../config/applications.yaml"
    )

    Test-Dependency -Command "gsudo" -Source "gerardog.gsudo" -App
    gsudo cache on | Out-Null

    # Load the YAML file
    try {
        Test-Dependency -Command "ConvertFrom-Yaml" -Module -Source "powershell-yaml"
        $yamlContent = Get-Content -Path $ConfigPath -Raw
        $appsConfig = ConvertFrom-Yaml $yamlContent
    }
    catch {
        throw "Failed to load applications YAML: $_"
    }

    # Determine which categories to install
    $categoriesToInstall = @()
    if ($All) {
        $categoriesToInstall = $appsConfig.Keys
    }
    else {
        foreach ($cat in @('Init','Core','Messengers','ProgrammingTools','Games')) {
        if ($PSBoundParameters.ContainsKey($cat) -and $PSBoundParameters[$cat]) {
            if ($appsConfig.ContainsKey($cat)) {
                $categoriesToInstall += $cat
            }
            else {
                Write-Error "Category '$cat' does not exist in config."
            }
        }
    }
    }

    if (-not $categoriesToInstall) {
        throw "No categories selected. Use -All or one of the category switches."
    }

    # Iterate through each category
    foreach ($cat in $categoriesToInstall) {
        Write-Verbose "Installing category '$cat'..."
        $categoryData = $appsConfig[$cat] 

        # Install modules
        if ($categoryData.modules) {
            foreach ($module in $categoryData.modules) {
                if ($PSCmdlet.ShouldProcess("Module: $module", "Install PowerShell module")) {
                    try {
                        Install-PSModule -ModuleName $module
                    }
                    catch {
                        Write-Error "Failed to install module '$module': $_"
                    }
                }
            }
        }

        # Install winget apps
        if ($categoryData.winget) {
            foreach ($appId in $categoryData.winget) {
                if ($PSCmdlet.ShouldProcess("App: $appId", "Install winget application")) {
                    try {
                        Install-App -AppId $appId
                    }
                    catch {
                        Write-Error "Failed to install app '$appId': $($_.Exception.Message)"
                        Write-Error "Call stack:`n$($_.ScriptStackTrace)"
                    }
                }
            }
        }
    }
    Write-Host "Successfully installed categories '$categoriesToInstall'." -ForegroundColor Green
}
