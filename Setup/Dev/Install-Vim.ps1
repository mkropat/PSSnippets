#Requires -RunAsAdministrator

[CmdletBinding()]
param(
    [string] $VimPackage = 'vim',
    [string] $VimrcUrl,
    [string[]] $Plugins = @(
        'bling/vim-airline',
        'ctrlpvim/ctrlp.vim',
        'mileszs/ack.vim',
        'mkropat/vim-dwiw2015',
        'tpope/vim-sensible',
        'tpope/vim-sleuth'
    )
)

$ErrorActionPreference = 'Stop'

$nvimrcPath = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) 'nvim\init.vim'
$nvimrc = "set runtimepath+=~/vimfiles,~/vimfiles/after
set packpath+=~/vimfiles
source ~/_vimrc"
if (-not (Test-Path $nvimrcPath)) {
    New-Item -ItemType Directory -Path (Split-Path $nvimrcPath) -ErrorAction SilentlyContinue | Out-Null
    $nvimrc | Out-File -Encoding ascii -NoNewline -FilePath $nvimrcPath
}

$vimrcPath = '~\_vimrc'
if (-not (Test-Path $vimrcPath)) {
    New-Item $vimrcPath | Out-Null
}

if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    if (@('AllSigned', 'Default', 'Restricted', 'Undefined') -contains (Get-ExecutionPolicy)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force
    }

    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    & choco install -y git
}

$bundleDir = '~\vimfiles\pack\bundle\start'
New-Item -ItemType Directory -Path $bundleDir -ErrorAction SilentlyContinue | Out-Null

foreach ($p in $Plugins) {
    $name = Split-Path -Leaf $p
    $pluginDir = Join-Path $bundleDir $name
    if (Test-Path $pluginDir) {
        Push-Location $pluginDir
        & git pull --ff-only
        Pop-Location
    }
    else {
        Push-Location $bundleDir
        & git clone "https://github.com/$p"
        Pop-Location
    }
}

if ($VimrcUrl -and -not (Test-Path ~\_vimrc)) {
    Invoke-WebRequest $VimrcUrl `
        -Headers @{'Cache-Control' = 'no-cache'} `
        -OutFile ~\_vimrc `
        -UseBasicParsing
}

& choco install -y $VimPackage
