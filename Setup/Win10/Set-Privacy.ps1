$ErrorActionPreference = 'Stop'

if (-not (Get-PackageProvider -ListAvailable | Where-Object Name -eq NuGet)) {
    Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Scope CurrentUser -Force
}

$gallery = Get-PSRepository PSGallery -ErrorAction SilentlyContinue
if ($gallery -and $gallery.InstallationPolicy -eq 'Untrusted') {
    Set-PSRepository PSGallery -InstallationPolicy Trusted
}

if (-not (Get-Command Set-Privacy.ps1 -ErrorAction SilentlyContinue)) {
    Install-Script Set-Privacy -Force -Scope CurrentUser
}

if (@('AllSigned', 'Default', 'Restricted', 'Undefined') -contains (Get-ExecutionPolicy)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
}

Write-Verbose "Setting privacy profile to 'Balanced'"
Set-Privacy.ps1 -Balanced