Get-HotFix |
    Select-Object InstalledOn, Description, HotFixID |
    Sort-Object InstalledOn -Descending |
    Format-Table -AutoSize | Out-String
