Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue |
    Where-Object { -not $_.PSIsContainer -and $_.Length -gt 500MB } |
    Select-Object FullName, @{Name="Size(GB)"; Expression={[math]::Round($_.Length/1GB, 2)}} |
    Sort-Object Length -Descending |
    Format-Table -AutoSize | Out-String
