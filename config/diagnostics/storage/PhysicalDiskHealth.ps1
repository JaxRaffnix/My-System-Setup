Get-PhysicalDisk |
    Select-Object DeviceID, FriendlyName, MediaType, HealthStatus, OperationalStatus |
    Format-Table -AutoSize | Out-String
