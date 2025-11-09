Get-CimInstance Win32_StartupCommand |
    Where-Object { $_.Command -and $_.Command.Trim() -ne "" } |
    Select-Object Name, Command, Location, User |
    Format-Table -AutoSize | Out-String
