Get-MpComputerStatus |
    Select-Object AMServiceEnabled, RealTimeProtectionEnabled, AntivirusEnabled, NISProtectionEnabled |
    Format-List | Out-String
