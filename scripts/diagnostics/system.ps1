# SYSTEM DIAGNOSTICS

# Windows Defender Status
Write-Host "Windows Defender Status:" -ForegroundColor Yellow
Get-MpComputerStatus |
    Select-Object AMServiceEnabled, RealTimeProtectionEnabled, AntivirusEnabled, NISProtectionEnabled |
    Format-List | Out-String

# System Reliability Issues (Last 7 Days)
Write-Host "System Reliability Issues (Last 7 Days):" -ForegroundColor Yellow
Get-WinEvent -FilterHashtable @{LogName="System"; StartTime=(Get-Date).AddDays(-7)} |
    Where-Object {$_.LevelDisplayName -eq "Error"} |
    Select-Object TimeCreated, ProviderName, Id, Message |
    Sort-Object TimeCreated -Descending |
    Format-Table -AutoSize | Out-String

# Startup Programs
Write-Host "Startup Programs:" -ForegroundColor Yellow
Get-CimInstance Win32_StartupCommand |
    Where-Object { $_.Command -and $_.Command.Trim() -ne "" } |
    Select-Object Name, Command, Location, User |
    Format-Table -AutoSize | Out-String

# DISM Health Check
Write-Host "Running DISM Health Check..." -ForegroundColor Yellow
gsudo DISM /Online /Cleanup-Image /RestoreHealth

# System File Checker
Write-Host "Running System File Checker..." -ForegroundColor Yellow
gsudo sfc /scannow

# Check Disk
Write-Host "Running Check Disk..." -ForegroundColor Yellow
Write-Output y | gsudo chkdsk C: /spotfix /F

# Pending Windows Updates
Write-Host "Checking for Pending Windows Updates..." -ForegroundColor Yellow
gsudo Get-WindowsUpdate -AcceptAll -IgnoreReboot | Format-Table | Out-String
