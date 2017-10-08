[CmdletBinding()]
param(
    [string[]]$Exclude = @(
        'Google Chrome'
    )
)

# Based on a post by Disassembler0: https://github.com/Disassembler0/Win10-Initial-Setup-Script/issues/8

$pinvoke = Add-Type -PassThru -Name pinvoke -MemberDefinition @'
[DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
internal static extern IntPtr GetModuleHandle(string moduleName);

[DllImport("user32.dll", CharSet = CharSet.Unicode)]
internal static extern int LoadString(IntPtr handle, uint id, System.Text.StringBuilder buffer, int bufferMax);

public static string GetModuleString(string moduleName, uint stringId) {
    var handle = GetModuleHandle(moduleName);
    if (handle == null)
        throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
    var buffer = new System.Text.StringBuilder(255);
    var length = LoadString(handle, stringId, buffer, buffer.Capacity);
    if (length == 0)
        throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());
    return buffer.ToString();
}
'@

$unpinFromStartTitle = $pinvoke::GetModuleString('shell32.dll', 51394)

$application = New-Object -ComObject Shell.Application
$applicationClassId = '4234d49b-0245-4df3-b780-3893943456e1'
$entries = $application.NameSpace("shell:::{$applicationClassId}").Items() | ForEach-Object {
    [PSCustomObject]@{
        Name = $_.Name
        UnpinVerb = $_.Verbs() | Where-Object Name -eq $unpinFromStartTitle
    }
}

$matching = $entries | Where-Object { $Exclude -notcontains $_.Name -and $_.UnpinVerb }
foreach ($item in $matching) {
    $item.UnpinVerb.DoIt()
}