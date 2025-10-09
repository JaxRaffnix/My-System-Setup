function New-UserFolders {
    <#
    .SYNOPSIS
    Creates user folders based on a YAML configuration, with optional Desktop shortcuts and Quick Access pins.

    .PARAMETER ConfigPath
    Path to the YAML configuration file.

    .EXAMPLE
    New-UserFolders -ConfigPath "C:\config\user_folders.yaml"
    #>

    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [string]$ConfigPath = "$PSScriptRoot/../config/folders.yaml"
    )

    Test-Dependency "Get-WindowsUpdate" -Module -Source "PSWindowsUpdate"

    try {
        $yamlContent = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Yaml
    } catch {
        throw "Failed to load YAML file '$ConfigPath': $_"
    }

    if (-not $yamlContent.folders) {
        throw "No folders defined in YAML file."
    }

    foreach ($folder in $yamlContent.folders) {
        # Expand environment variables in path
        $basePath = [Environment]::ExpandEnvironmentVariables($folder.Path)
        $fullPath = Join-Path -Path $basePath -ChildPath $folder.Name

        try {
            if (-not (Test-Path $fullPath)) {
                New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
                Write-verbose "Created folder: '$fullPath'" 
            } else {
                Write-Warning "Folder already exists: '$fullPath'" 
            }
        } catch {
            Write-Error "Failed to create folder '$fullPath': $($_.Exception.Message)"
            continue
        }

        # Optional Desktop shortcut
        if ($folder.enable_shortcut) {
            try {
                Add-Shortcut -TargetPath $fullPath
            } catch {
                Write-Error "Failed to create Desktop shortcut for '$fullPath': $_"
            }
        }

        # Optional Quick Access pin
        if ($folder.enable_quick_access) {
            try {
                Switch-ToQuickAccess -FolderPath $fullPath
            } catch {
                Write-Error "Failed to pin '$fullPath' to Quick Access: $_"
            }
        }
    }

    Write-verbose "Finished processing folders from YAML." 
}
