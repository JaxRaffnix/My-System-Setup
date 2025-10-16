if (-not (Get-Command "gsudo" -ErrorAction SilentlyContinue)) {
    Write-Warning "Installing missing winget app 'gerardog.gsudo'..."
    winget install --id gerardog.gsudo --silent --accept-source-agreements --accept-package-agreements
}

if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    gsudo Install-PackageProvider -Name NuGet -Force
}

Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# Import all private helpers
Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -Recurse | ForEach-Object {
     . $_.FullName
}

# Import all public functions
Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -Recurse | ForEach-Object {
     . $_.FullName
}
