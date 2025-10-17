function Invoke-GitAmend {
    <#
    .SYNOPSIS
    Amends the most recent Git commit, optionally pushing changes to the remote.

    .DESCRIPTION
    This function automates the process of amending the latest Git commit. 
    It stages all modified files, amends the last commit (optionally with a new message),
    and optionally pushes the amended commit to the remote repository.

    It also checks if the local branch is behind or has diverged from the remote and 
    performs a `git pull` if necessary before amending.

    .PARAMETER Path
    The path to the Git repository. Defaults to the current directory.

    .PARAMETER Message
    The new commit message to use for the amended commit.
    If omitted, the Git editor will open for you to modify the message.

    .PARAMETER Push
    If specified, pushes the amended commit to the remote repository.

    .EXAMPLE
    Invoke-GitAmend -Message "Fix typo in README"
    # Stages all changes and amends the latest commit with a new message.

    .EXAMPLE
    Invoke-GitAmend -Push
    # Amends the latest commit interactively, then pushes to remote.

    #>
    param (
        [string]$Path = ".",  # optional: path to the git repo
        [string]$Message,
        [switch]$Push
    )

    Test-Dependency "git" -Source "git.git" -App

    Write-Verbose "Changing location to repository: $Path"
    Push-Location $Path

    try {
        git fetch | Out-Null

        $status = git status -uno
        if ($status -match "Your branch is behind" -or $status -match "have diverged") {
            Write-Host "Pulling latest changes to sync with remote ..."
            git pull
        }

        git add -A

        if ($Message) {
            git commit --amend -m $Message
        } else {
            git commit --amend --no-edit
        }

        if ($Push) {
            git pull
            git push
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

