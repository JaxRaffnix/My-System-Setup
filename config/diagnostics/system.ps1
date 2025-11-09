# SYSTEM DIAGNOSTICS

Write-Host "Running System Diagnostics..." -ForegroundColor Yellow

# Windows Defender Status
Get-MpComputerStatus |
    Select-Object AMServiceEnabled, RealTimeProtectionEnabled, AntivirusEnabled, NISProtectionEnabled |
    Format-List | Out-String

# System Reliability Issues (Last 7 Days)
Get-WinEvent -FilterHashtable @{LogName="System"; StartTime=(Get-Date).AddDays(-7)} |
    Where-Object {$_.LevelDisplayName -eq "Error"} |
    Select-Object TimeCreated, ProviderName, Id, Message |
    Sort-Object TimeCreated -Descending |
    Format-Table -AutoSize | Out-String

# Startup Programs
Get-CimInstance Win32_StartupCommand |
    Where-Object { $_.Command -and $_.Command.Trim() -ne "" } |
    Select-Object Name, Command, Location, User |
    Format-Table -AutoSize | Out-String

# DISM Health Check
gsudo DISM /Online /Cleanup-Image /RestoreHealth

# System File Checker
gsudo sfc /scannow

# Check Disk
gsudo chkdsk C: /spotfix

# Installed Updates
Get-HotFix |
    Select-Object InstalledOn, Description, HotFixID |
    Sort-Object InstalledOn -Descending |
    Format-Table -AutoSize | Out-String

# Pending Windows Updates
gsudo Get-WindowsUpdate -AcceptAll -IgnoreReboot | Format-Table | Out-String
