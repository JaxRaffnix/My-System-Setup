function Install-Applications {
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

        Write-Verbose "Finished category '$cat'."
    }
}
