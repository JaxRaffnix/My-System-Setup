Get-PSDrive -PSProvider FileSystem |
    Select-Object Name, Used, Free, @{Name="Used(%)"; Expression={[math]::Round(($_.Used / ($_.Used + $_.Free)) * 100, 2)}} |
    Format-Table -AutoSize | Out-String
