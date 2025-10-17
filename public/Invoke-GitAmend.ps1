function Invoke-GitAmend {
    <#
    .SYNOPSIS
    Amends the most recent Git commit and automatically syncs with remote if applicable.

    .DESCRIPTION
    Stages all changes, amends the most recent commit (optionally with a new message),
    and automatically pushes the amended commit to the remote repository if the branch
    is tracking one. This avoids divergence and merge conflicts entirely.

    .PARAMETER Path
    The path to the Git repository. Defaults to the current directory.

    .PARAMETER Message
    The new commit message to use for the amended commit.
    If omitted, the previous message is reused.

    .PARAMETER NoPush
    Suppresses automatic pushing (for local-only amend).

    .EXAMPLE
    Invoke-GitAmend -Message "Fix typo in docs"
    # Amends and automatically syncs with remote if tracking branch exists.

    .EXAMPLE
    Invoke-GitAmend -NoPush
    # Amends locally without updating the remote.
    #>
    param (
        [string]$Path = ".",  # optional: path to the git repo
        [string]$Message,
        [switch]$NoPush
    )

    Test-Dependency "git" -Source "git.git" -App

    Write-Verbose "Changing location to repository: $Path"
    Push-Location $Path

    try {
        git fetch --quiet | Out-Null

        $status = git status -uno
        if ($status -match "Your branch is behind" -or $status -match "have diverged") {
            Write-Warning "Remote branch has changed since your last push. Your amend will overwrite it."
        }

        git add -A

        if ($Message) {
            git commit --amend -m $Message
        } else {
            git commit --amend --no-edit
        }

        $remoteHash = git rev-parse '@{u}' 2>$null
        if (-not $NoPush -and $remoteHash) {
            Write-Verbose "Branch has a remote tracking branch. Auto-pushing amended commit..."
            git push --force-with-lease
        }
        elseif ($NoPush) {
            Write-Verbose "No push to remote requested."
        }
        else {
            Write-Verbose "No remote tracking detected."
        }

        Write-Host "Successfully amended latest commit." -ForegroundColor Green
    } catch {
        Throw "Failed to amend latest commit: $_"
    } finally {
        Pop-Location
    }
}

# Create a short alias
Set-Alias ga Invoke-GitAmend
Set-Alias Git-Amend Invoke-GitAmend
