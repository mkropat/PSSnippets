#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [string] $PresetUrl
)

if (@('AllSigned', 'Default', 'Restricted', 'Undefined') -contains (Get-ExecutionPolicy)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
}

if ($PresetUrl) {
    Invoke-WebRequest $PresetUrl `
        -Headers @{'Cache-Control' = 'no-cache'} `
        -OutFile "$TEMP\$(Split-Path -Leaf $PresetUrl) `
        -UseBasicParsing
}

$scriptUrl = 'https://raw.githubusercontent.com/Disassembler0/Win10-Initial-Setup-Script/master/Win10.ps1'
(New-Object Net.WebClient).DownloadString($url) | Out-File "$env:TEMP\$(Split-Path -Leaf $scriptUrl)"

if ($PresetUrl) {
    & "$env:TEMP\$(Split-Path -Leaf $scriptUrl)" -Preset "$TEMP\$(Split-Path -Leaf $PresetUrl)
}
else {
    Invoke-Comand "$env:TEMP\$(Split-Path -Leaf $scriptUrl)" -ArgumentList $args
}
