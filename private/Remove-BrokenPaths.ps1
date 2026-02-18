function Remove-BrokenPaths {

    [CmdletBinding(SupportsShouldProcess)]
    param(
        [switch]$VerboseOutput
    )

    <#
    .SYNOPSIS
        Removes non-existing directories from User and System PATH.

    .DESCRIPTION
        Reads the current User and System PATH environment variables,
        removes entries that do not exist on disk, and writes back
        the cleaned PATH. Idempotent and safe.
        Supports -WhatIf and -Confirm.

    .PARAMETER VerboseOutput
        Prints all retained PATH entries.

    .EXAMPLE
        Remove-BrokenPaths -VerboseOutput

    .EXAMPLE
        Remove-BrokenPaths -WhatIf
    #>

    $Scopes = @("User", "Machine")

    foreach ($scope in $Scopes) {

        Write-Host "`nProcessing $scope PATH..." -ForegroundColor Cyan

        $CurrentPath = [Environment]::GetEnvironmentVariable("Path", $scope)
        if (-not $CurrentPath) { 
            Write-Verbose "$scope PATH is empty. Skipping."
            continue
        }

        $PathEntries = $CurrentPath -split ';'
        $CleanedEntries = [System.Collections.Generic.List[string]]::new()
        $RemovedCount = 0

        # Case-insensitive HashSet for deduplication
        $PathSet = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)

        foreach ($entry in $PathEntries) {

            if (-not $entry.Trim()) { continue }

            $expanded = [Environment]::ExpandEnvironmentVariables($entry)

            if (Test-Path $expanded) {
                $resolved = (Resolve-Path -LiteralPath $expanded -ErrorAction SilentlyContinue)?.Path
                $normalized = ($resolved ?? $expanded).TrimEnd('\')

                if ($PathSet.Add($normalized)) {
                    $CleanedEntries.Add($normalized)
                    if ($VerboseOutput) { Write-Verbose "Keeping: $normalized" }
                }
            }
            else {
                Write-Warning "Removing broken path: $expanded"
                $RemovedCount++
            }
        }

        if ($RemovedCount -eq 0) {
            Write-Host "No broken PATH entries found in $scope PATH."
            continue
        }

        $NewPath = ($CleanedEntries -join ';')

        if ($PSCmdlet.ShouldProcess("$scope PATH", "Remove $RemovedCount broken entries")) {
            [Environment]::SetEnvironmentVariable("Path", $NewPath, $scope)
            Write-Host "Removed $RemovedCount broken entries from $scope PATH."
        }
    }
    Write-Host "PATH cleaned successfully. Restart terminal to apply changes." -ForegroundColor Green
}