#Requires -RunAsAdministrator

$ErrorActionPreference = 'Stop'

Remove-Item -Force -Recurse $env:WINDIR\System32\GroupPolicy
Remove-Item -Force -Recurse $env:WINDIR\System32\GroupPolicyUsers

& gpupdate /force

& secedit /configure /cfg $env:WINDIR\inf\defltbase.inf /db defltbase.sdb /verbose