#Requires -RunAsAdministrator

[CmdletBinding(PositionalBinding=$False)]
param(
    [Parameter(Mandatory=$False, ValueFromPipeline=$true)]
    [string] $PresetUrl,

    [Parameter(Mandatory=$False, Position=0, ValueFromRemainingArguments=$True)]
    [object[]] $Arguments
)

$ErrorActionPreference = 'Stop'

if (@('AllSigned', 'Default', 'Restricted', 'Undefined') -contains (Get-ExecutionPolicy)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
}

if ($PresetUrl) {
    Invoke-WebRequest $PresetUrl `
        -Headers @{'Cache-Control' = 'no-cache'} `
        -OutFile "$env:TEMP\$(Split-Path -Leaf $PresetUrl)" `
        -UseBasicParsing
}

$moduleUrl = 'https://raw.githubusercontent.com/Disassembler0/Win10-Initial-Setup-Script/master/Win10.psm1'
(New-Object Net.WebClient).DownloadString($moduleUrl) | Out-File "$env:TEMP\$(Split-Path -Leaf $moduleUrl)"

Import-Module "$env:TEMP\$(Split-Path -Leaf $moduleUrl)"

$scriptUrl = 'https://raw.githubusercontent.com/Disassembler0/Win10-Initial-Setup-Script/master/Win10.ps1'
(New-Object Net.WebClient).DownloadString($scriptUrl) | Out-File "$env:TEMP\$(Split-Path -Leaf $scriptUrl)"

if ($PresetUrl) {
    & "$env:TEMP\$(Split-Path -Leaf $scriptUrl)" -Preset "$env:TEMP\$(Split-Path -Leaf $PresetUrl)"
}
else {
    & "$env:TEMP\$(Split-Path -Leaf $scriptUrl)" @Arguments
}
