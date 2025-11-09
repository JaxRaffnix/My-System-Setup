# STORAGE DIAGNOSTICS

Write-Host "Running Storage Diagnostics..." -ForegroundColor Yellow

# Physical Disk Health
Get-PhysicalDisk |
    Select-Object DeviceID, FriendlyName, MediaType, HealthStatus, OperationalStatus |
    Format-Table -AutoSize | Out-String

# Disk Usage Summary
Get-PSDrive -PSProvider FileSystem |
    Select-Object Name, Used, Free, @{Name="Used(%)"; Expression={[math]::Round(($_.Used / ($_.Used + $_.Free)) * 100, 2)}} |
    Format-Table -AutoSize | Out-String

# Large Files (>500MB)
Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue |
    Where-Object { -not $_.PSIsContainer -and $_.Length -gt 500MB } |
    Select-Object FullName, @{Name="Size(GB)"; Expression={[math]::Round($_.Length/1GB, 2)}} |
    Sort-Object Length -Descending |
    Format-Table -AutoSize | Out-String
