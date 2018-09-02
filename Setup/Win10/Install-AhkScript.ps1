#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    $Script
)

$ErrorActionPreference = 'Stop'

$ahkAssociation = Get-ItemProperty Registry::HKEY_CLASSES_ROOT\.ahk -ErrorAction SilentlyContinue | Select-Object -ExpandProperty '(default)'
if ($ahkAssociation -ne 'AutoHotkeyScript') {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        if (@('AllSigned', 'Default', 'Restricted', 'Undefined') -contains (Get-ExecutionPolicy)) {
            Set-ExecutionPolicy Bypass -Scope Process -Force
        }

        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    
    choco install -y autohotkey
}

$scriptItem = Get-Item $Script

$lnkPath = Join-Path ([Environment]::GetFolderPath('Startup')) "$($scriptItem.BaseName).lnk"

$wsh = New-Object -ComObject WScript.Shell
$shortcut = $wsh.CreateShortcut($lnkPath)
$shortcut.TargetPath = $scriptItem.FullName
$shortcut.Save()

& $lnkPath
