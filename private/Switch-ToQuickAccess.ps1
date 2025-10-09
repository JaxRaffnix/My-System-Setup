function Switch-ToQuickAccess {
    <#
    .SYNOPSIS
    Pins a folder to Quick Access in File Explorer.

    .DESCRIPTION
    Uses Windows Shell COM to pin the folder to Quick Access.

    .PARAMETER FolderPath
    Full path to the folder to pin.

    .EXAMPLE
    Switch-ToQuickAccess -FolderPath "$env:USERPROFILE\Projects"
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$FolderPath
    )

    try {
        $Shell = New-Object -ComObject Shell.Application
        $Namespace = $Shell.Namespace($FolderPath)
        if ($Namespace) {
            $Namespace.Self.InvokeVerb("pintohome")
            Write-Verbose "Folder added to Quick Access: '$FolderPath'"
        } else {
            throw "Cannot access folder: '$FolderPath'"
        }

    } catch {
        Write-Error "Failed to pin to Quick Access: $($_.Exception.Message)"
    }
}
