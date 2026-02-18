# CLEANUP TASKS

Write-Host "Running Cleanup Tasks..." -ForegroundColor Yellow

# Remove Broken Shortcuts
$Paths = @(
    "$env:USERPROFILE\Desktop",
    "$env:PUBLIC\Desktop",
    "$env:APPDATA\Microsoft\Windows\Start Menu",
    "$env:ProgramData\Microsoft\Windows\Start Menu"
)
Remove-UnwantedShortcuts -Paths $Paths -RemoveBroken

# Disk Cleanup
cleanmgr /sagerun:1 /autoclean

# Empty Recycle Bin
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# Clear Temp and Cache
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*" -Recurse -Force -ErrorAction SilentlyContinue

# clear broken path environment variables
Remove-BrokenPaths
