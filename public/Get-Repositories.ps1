<#
.SYNOPSIS
    Clone repositories defined in a YAML configuration into a target directory.

.DESCRIPTION
    Get-Repositories reads a YAML file (default: ../config/repositories.yaml relative to the script)
    which contains a 'repositories' list with objects that include at least 'Name' and 'Url' fields.
    For each repository entry the function will create the target directory if it does not exist,
    skip repositories that already exist at the destination, and attempt to clone the remaining
    repositories using 'git clone'. This cmdlet supports WhatIf/Confirm via SupportsShouldProcess.

.PARAMETER TargetPath
    Path to the directory where repositories will be cloned. This parameter is mandatory.

.PARAMETER ConfigPath
    Path to the repositories YAML configuration file. Defaults to "$PSScriptRoot/../config/repositories.yaml".

.EXAMPLE
    Get-Repositories -TargetPath 'C:\src\repos'

.EXAMPLE
    Get-Repositories -TargetPath 'C:\src\repos' -ConfigPath 'C:\config\my-repos.yaml'
#>

function Get-Repositories {

    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory=$true)]
        [string]$TargetPath,   

        [Parameter(Mandatory=$false)]
        [string]$ConfigPath = "$PSScriptRoot/../config/repositories.yaml"
    )

    # Load YAML
    Test-Dependency -Command "ConvertFrom-Yaml" -Module -Source "powershell-yaml"
    try {
        $yamlContent = Get-Content -Path $ConfigPath -Raw
        $repos = ConvertFrom-Yaml $yamlContent
    }
    catch {
        throw "Failed to load repositories YAML: $_"
    }

    # Ensure the target directory exists
    if (-not (Test-Path $TargetPath)) {
        try {
            New-Item -Path $TargetPath -ItemType Directory -Force | Out-Null
            Write-Verbose "Created target directory: $TargetPath"
        } catch {
            throw "Failed to create directory '$TargetPath': $_"
        }
    }

    foreach ($repo in $repos.repositories) {
        $clonePath = Join-Path $TargetPath $repo.Name

        if (Test-Path $clonePath) {
            Write-Warning "Repository '$($repo.Name)' already exists at '$clonePath'. Skipping."
            continue
        }

        if ($PSCmdlet.ShouldProcess($clonePath, "Clone repository $($repo.Name)")) {
            Write-Verbose "Cloning repository '$($repo.Name)' to '$clonePath'..."
            try {
                git clone $repo.Url $clonePath
                Write-Verbose "Successfully cloned '$($repo.Name)'."
            } catch {
                Write-Error "Failed to clone '$($repo.Name)': $_"
            }
        }
    }
    Write-Host "Successfully cloned repositories to '$TargetPath'." -ForegroundColor Green
}
