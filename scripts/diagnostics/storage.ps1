# STORAGE DIAGNOSTICS

# Physical Disk Health
Write-Host "Physical Disk Health:" -ForegroundColor Yellow
Get-PhysicalDisk |
    Select-Object DeviceID, FriendlyName, MediaType, HealthStatus, OperationalStatus |
    Format-Table -AutoSize | Out-String

# Disk Usage Summary
Write-Host "Disk Usage Summary:" -ForegroundColor Yellow
Get-PSDrive -PSProvider FileSystem |
    Select-Object Name, @{Name="Used(GB)"; Expression={[math]::Round($_.Used/1GB, 2)}}, @{Name="Free(GB)"; Expression={[math]::Round($_.Free/1GB, 2)}}, @{Name="Used(%)"; Expression={[math]::Round(($_.Used / ($_.Used + $_.Free)) * 100, 2)}} |
    Format-Table -AutoSize | Out-String

# Large Files (>500MB)
Write-Host "Large Files (>500MB):" -ForegroundColor Yellow
Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue |
    Where-Object { -not $_.PSIsContainer -and $_.Length -gt 500MB } |
    Select-Object FullName, @{Name="Size(GB)"; Expression={[math]::Round($_.Length/1GB, 2)}} |
    Sort-Object Length -Descending |
    Format-Table -AutoSize | Out-String
