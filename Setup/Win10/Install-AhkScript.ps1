#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string] $ScriptUrl
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

$scriptPath = Join-Path ([Environment]::GetFolderPath('MyDocuments')) (Split-Path -Leaf $ScriptUrl)

Invoke-WebRequest $ScriptUrl `
    -Headers @{'Cache-Control' = 'no-cache'} `
    -OutFile $scriptPath `
    -UseBasicParsing

$script = Get-Item $scriptPath

$lnkPath = Join-Path ([Environment]::GetFolderPath('Startup')) "$($script.BaseName).lnk"

$wsh = New-Object -ComObject WScript.Shell
$shortcut = $wsh.CreateShortcut($lnkPath)
$shortcut.TargetPath = $script.FullName
$shortcut.Save()

& $lnkPath
