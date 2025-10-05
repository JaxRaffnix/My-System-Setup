function Clone-Repositories {

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
}
