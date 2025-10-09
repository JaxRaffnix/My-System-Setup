function Add-Shortcut {
    <#
    .SYNOPSIS
    Creates a desktop shortcut to a given folder.

    .DESCRIPTION
    Creates a `.lnk` file on the desktop that links to the specified folder.

    .PARAMETER TargetPath
    The full path of the folder to create a shortcut for.

    .EXAMPLE
    Add-Shortcut -TargetPath "$env:USERPROFILE\Projects"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$TargetPath
    )

    try {
        $desktop = [Environment]::GetFolderPath("Desktop")
        $shortcutName = "$([System.IO.Path]::GetFileName($TargetPath)).lnk"
        $shortcutPath = Join-Path $desktop $shortcutName

        if (Test-Path $shortcutPath) {
            $shell = New-Object -ComObject WScript.Shell
            $existingShortcut = $shell.CreateShortcut($shortcutPath)

            if ($existingShortcut.TargetPath -eq $TargetPath) {
                Write-Warning "Shortcut already exists and points to the correct target: '$shortcutPath'"
                return 
            } else {
                Write-Warning "Shortcut exists but points to a different target. Overwriting: '$shortcutPath'"
            }
        }

        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $TargetPath
        $shortcut.Save()

        Write-Verbose "Shortcut created: '$shortcutPath'"
    } catch {
        Write-Error "Failed to create shortcut for '$TargetPath': $($_.Exception.Message)"
    }
}
