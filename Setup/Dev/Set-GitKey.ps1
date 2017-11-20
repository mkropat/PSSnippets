[CmdletBinding()]
param(
    [string] $SshKeyPath
)

$ErrorActionPreference = 'Stop'

if (-not $SshKeyPath) {
  $SshKeyPath = Join-Path ([Environment]::GetFolderPath("MyDocuments")) 'git.ppk'
}

$sshKey = Get-Item $SshKeyPath
if ($sshKey.Extension -ne '.ppk') {
    throw 'Expected $SshKeyPath to end in .ppk'
}

if (-not (Get-Command plink)) {
    & choco install -y putty
}

$sshPath = Get-Command plink | Select-Object -ExpandProperty Path
if ($env:GIT_SSH -ne $sshPath) {
    $env:GIT_SSH = $sshPath
    [Environment]::SetEnvironmentVariable('GIT_SSH', $env:GIT_SSH, [EnvironmentVariableTarget]::User)
}

$lnkPath = Join-Path ([Environment]::GetFolderPath('Startup')) 'pageant.lnk'

$sshAgent = Get-Command pageant | Select-Object -ExpandProperty Path

$wsh = New-Object -ComObject WScript.Shell
$shortcut = $wsh.CreateShortcut($lnkPath)
$shortcut.TargetPath = "`"$sshAgent`""
$shortcut.Arguments = "`"$($sshKey.FullName)`""
$shortcut.Save()

& $lnkPath
