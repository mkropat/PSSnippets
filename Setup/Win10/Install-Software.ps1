#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [string[]] $Software = @(
        '7zip',
        'googlechrome'
    )
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    if (@('AllSigned', 'Default', 'Restricted', 'Undefined') -contains (Get-ExecutionPolicy)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force
    }

    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

$Software | ForEach-Object {
    choco install -y $_
}