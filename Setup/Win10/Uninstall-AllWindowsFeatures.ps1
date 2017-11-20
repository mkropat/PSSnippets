#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [string[]] $WhitelistedFeatures = @(
        'Microsoft-Windows-HyperV-Guest-Package',
        'MediaPlayback',
        'WindowsMediaPlayer',
        'TelnetClient',
        'FaxServicesClientPackage'
    )
)

$enabledFeatures = Get-WindowsOptionalFeature -Online | Where-Object State -eq Enabled | Select-Object -ExpandProperty FeatureName
$featuresToUninstall = $enabledFeatures | Where-Object { $WhitelistedFeatures -notcontains $_ }
$featuresToUninstall | ForEach-Object {
    Write-Verbose "Uninstalling $_"
    Disable-WindowsOptionalFeature -Online -FeatureName $_ -NoRestart | Out-Null
}