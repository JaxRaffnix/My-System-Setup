function Add-Commit {
    <#
    .SYNOPSIS
    runs git commands add, commit and push in a single line.

    .DESCRIPTION
    Stages all changes, commits them with an optional message. 

    .PARAMETER Path
    The path to the Git repository. Defaults to the current directory.

    .PARAMETER Message
    The new commit message to use for the amended commit.
    If omitted, the previous message is reused.

    .PARAMETER Push
    Enables automatic pushing.

    .EXAMPLE
    Add-Commit -Message "Fix typo in docs"
    # Adds and commits changes to the remote repository.

    .EXAMPLE
    Add-Commit -Push -Message "Update README.md"
    # Adds, commits and pushes changes to the remote repository.
    #>
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrWhiteSpace()]
        [string]$Message,
        [string]$Path = ".",  # optional: path to the git repo
        [switch]$Push
    )

    Test-Dependency "git" -Source "git.git" -App

    Write-Verbose "Changing location to repository: $Path"
    if (-not (Test-Path -Path $Path)) {
        Throw "Specified path '$Path' does not exist."
    }
    Push-Location $Path

    # Exit if not a git repo
    $gitStatus = git rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or $gitStatus -ne 'true') {
        Throw "Path '$Path' is not a git repository."
    }

    try {
        $status = git status -uno
        if ($status -match "Your branch is behind" -or $status -match "have diverged") {
            Write-Warning "Remote branch has changed since your last push. Your Push will overwrite it."
        }

        git add -A

        $hasChanges = (git status --porcelain).Length -gt 0
        if (-not $hasChanges) {
            Write-Host "No changes detected." -ForegroundColor Green
            return
        }

        git commit -m $Message

        $remoteHash = git rev-parse '@{u}' 2>$null
        if ($Push -and $remoteHash) {
            Write-Verbose "Branch has a remote tracking branch. Pushing new commit..."
            git push
        }
        elseif ($Push -and -not $remoteHash) {
            Write-Warning "No remote tracking branch detected. Cannot push changes."
        }
        else {
            Write-Verbose "Push not requested. Commit created locally."
        }

        Write-Host "Successfully added and committed latest commit." -ForegroundColor Green
    } catch {
        Throw "Failed to commit latest changes: $_"
    } finally {
        Pop-Location
    }
}