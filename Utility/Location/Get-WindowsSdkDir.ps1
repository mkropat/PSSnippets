if (-not (Test-Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots')) {
    throw "Unable to locate Windows 10 SDK. Have you installed it?"
}

$sdkDir = Get-ItemPropertyValue "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots" -Name KitsRoot10
$includeDir = Join-Path $sdkDir 'Include'
$newestVersion = Get-ChildItem $includeDir |
    sort Name -Descending |
    select -First 1 -ExpandProperty Name

Join-Path $includeDir $newestVersion