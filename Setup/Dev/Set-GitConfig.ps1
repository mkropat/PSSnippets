[CmdletBinding()]
param(
    [string] $Name,
    [string] $Email
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        if (@('AllSigned', 'Default', 'Restricted', 'Undefined') -contains (Get-ExecutionPolicy)) {
            Set-ExecutionPolicy Bypass -Scope Process -Force
        }

        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    
    & choco install -y git
}

git config --global core.commentchar ";"
git config --global push.default simple
git config --global core.autocrlf input

git config --global alias.ci 'commit --verbose'
git config --global alias.co checkout
git config --global alias.dc 'diff --cached'
git config --global alias.di diff
git config --global alias.ff 'merge --ff-only'
git config --global alias.noff 'merge --no-ff'
git config --global alias.pullff 'pull --ff-only'
git config --global alias.st 'status --short'

if ($Name) {
    git config --global user.name $Name
}

if ($Email) {
    git config --global user.email $Email
}
