#Requires -RunAsAdministrator

function Get-WebFile {
    param(
        [Parameter(Mandatory=$true)]
        $Uri,
        [string] $OutFile,
        [string] $Hash,
        [string] $HashAlgorithm = 'SHA256'
    )

    if (-not $OutFile) {
        $OutFile = Split-Path -Leaf $Uri
    }

    $meta = Get-Item $OutFile -ErrorAction SilentlyContinue
    if ($meta -and $meta.PSIsContainer) {
        throw '$OutFile may not be a directory'
    }

    $container = Split-Path $OutFile
    if (-not $container) {
        $container = '.'
    }

    $tempFile = Join-Path $container "$(New-Guid).part"
    Invoke-WebRequest $Uri -OutFile $tempFile -ErrorAction Stop -UseBasicParsing

    if ($Hash) {
        $actual = Get-FileHash $tempFile -Algorithm $HashAlgorithm
        if ($Hash -ne $actual.Hash) {
            throw "Downloaded file does not have the expected $HashAlgorithm hash: $Hash"
        }
    }

    Move-Item $tempFile $OutFile -Force

    Get-Item $OutFile
}

$container = [Environment]::GetFolderPath("MyDocuments")
$baselineDir = Join-Path $container 'Windows 10 RS2 Security Baseline'

if (-not (Get-Item $baselineDir -ErrorAction SilentlyContinue)) {
    $zip = Join-Path $Env:Temp "$(New-Guid).zip"
    Get-WebFile 'https://msdnshared.blob.core.windows.net/media/2017/08/Windows-10-RS2-Security-Baseline-FINAL.zip' `
        -OutFile $zip `
        -Hash 8A5C8E782097518D2A5233ECFB18B1E04CE2D0093E7A6B6CE620FC30248E003A | Out-Null
    Expand-Archive $zip -DestinationPath $container
    Remove-Item $zip
}

$lgpoPath = Join-Path $baselineDir 'Local_Script\Tools\LGPO.exe'
if (-not (Get-Item $lgpoPath -ErrorAction SilentlyContinue)) {
    $zip = Join-Path $Env:Temp "$(New-Guid).zip"
    Get-WebFile 'https://download.microsoft.com/download/8/5/C/85C25433-A1B0-4FFA-9429-7E023E7DA8D8/LGPO.zip' `
        -OutFile $zip `
        -Hash 6FFB6416366652993C992280E29FAEA3507B5B5AA661C33BA1AF31F48ACEA9C4 | Out-Null
    Expand-Archive $zip (Split-Path $lgpoPath)
    Remove-Item $zip
}

Write-Verbose "Installings Windows 10 RS2 Security Baseline"
& "$baselineDir\Local_Script\Client_Install.cmd"