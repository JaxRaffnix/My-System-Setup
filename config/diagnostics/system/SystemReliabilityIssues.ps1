Get-WinEvent -FilterHashtable @{LogName="System"; StartTime=(Get-Date).AddDays(-7)} |
    Where-Object {$_.LevelDisplayName -eq "Error"} |
    Select-Object TimeCreated, ProviderName, Id, Message |
    Sort-Object TimeCreated -Descending |
    Format-Table -AutoSize | Out-String
