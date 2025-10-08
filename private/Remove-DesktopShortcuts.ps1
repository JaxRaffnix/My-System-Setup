function Remove-DesktopShortcuts {
    <#
    .SYNOPSIS
        Removes unwanted application shortcuts from desktop(s).

    .DESCRIPTION
        Iterates over user and public desktops and removes any shortcuts (*.lnk) 
        that are NOT listed in the allowed shortcuts array.

    .PARAMETER AllowedShortCuts
        An array of shortcut names to keep. Any other shortcuts will be removed.

    .PARAMETER DryRun
        If set, only simulates the removal without actually deleting shortcuts.

    .EXAMPLE
        Remove-DesktopShortcuts -AllowedShortCuts @("GitHub Desktop.lnk","VSCode.lnk")

    .EXAMPLE
        Remove-DesktopShortcuts -AllowedShortCuts @("GitHub Desktop.lnk") -DryRun
    #>

    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$AllowedShortCuts,

        [switch]$DryRun
    )

    $UserDesktopPath = Join-Path $env:USERPROFILE "Desktop"
    $PublicDesktopPath = "C:\Users\Public\Desktop"
    $DesktopPaths = @($UserDesktopPath, $PublicDesktopPath)

    foreach ($FilePath in $DesktopPaths) {
        if (-not (Test-Path $FilePath)) {
            Write-Warning "The path '$FilePath' does not exist. Skipping..."
            continue
        }

        Write-Verbose "Processing shortcuts in '$FilePath'"

        $CurrentShortCuts = Get-ChildItem $FilePath -Filter "*.lnk" -ErrorAction SilentlyContinue

        foreach ($ShortCut in $CurrentShortCuts) {
            if ($AllowedShortCuts -notcontains $ShortCut.Name) {
                if ($PSCmdlet.ShouldProcess($ShortCut.FullName, "Remove shortcut")) {
                    try {
                        if ($DryRun) {
                            Write-Host "[DryRun] Would remove: $($ShortCut.Name)" -ForegroundColor Yellow
                        } else {
                            gsudo Remove-Item $ShortCut.FullName -Force -ErrorAction Stop
                            Write-Host "Removed shortcut: $($ShortCut.Name)"
                        }
                    } catch {
                        throw "Failed to remove shortcut '$($ShortCut.Name)': $_"
                    }
                }
            } else {
                Write-Verbose "Keeping shortcut: $($ShortCut.Name)"
            }
        }
    }

    Write-Verbose "Finished processing all desktops."
}
