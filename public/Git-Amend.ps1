function Git-Amend {
    param (
        [string]$Path = "."  # optional: path to the git repo
    )

    Push-Location $Path

    try {
        # Stage all changes
        git add -A

        # Amend last commit and open VS Code for the commit message
        git commit --amend

    } finally {
        Pop-Location
    }
}

# Create a short alias
Set-Alias ga Git-Amend
