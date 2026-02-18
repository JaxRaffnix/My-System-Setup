# CLEANUP TASKS

# Remove Broken Shortcuts
Write-Host "Removing Broken Shortcuts..." -ForegroundColor Yellow
$Paths = @(
    "$env:USERPROFILE\Desktop",
    "$env:PUBLIC\Desktop",
    "$env:APPDATA\Microsoft\Windows\Start Menu",
    "$env:ProgramData\Microsoft\Windows\Start Menu"
)
Remove-UnwantedShortcuts -Paths $Paths -RemoveBroken

# Disk Cleanup
Write-Host "Running Disk Cleanup..." -ForegroundColor Yellow
cleanmgr /sagerun:1 /autoclean

# Clear Temp and Cache
Write-Host "Clearing Temporary Files and Cache..." -ForegroundColor Yellow
Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*" -Recurse -Force -ErrorAction SilentlyContinue

# clear broken path environment variables
Write-Host "Removing Broken Path Environment Variables..." -ForegroundColor Yellow
Remove-BrokenPaths

# Empty Recycle Bin
Write-Host "Emptying Recycle Bin..." -ForegroundColor Yellow
Clear-RecycleBin -Force -ErrorAction SilentlyContinue