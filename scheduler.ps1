[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification='Not sensitive')]
param (
    [Parameter(Mandatory=$true, Position=0, HelpMessage="Your campus wifi username")]
    [Alias("user")]
    [string]$Username,

    [Parameter(Mandatory=$true, Position=1, HelpMessage="Your campus wifi password")]
    [Alias("pwd")]
    [string]$Password,

    [Parameter(Mandatory=$false, HelpMessage="MEANT FOR INTERNAL USE ONLY. DO NOT USE PASS AS PARAMETER!")]
    [string]$LoginScriptPath = $null
)

$taskName = "PulchowkWifiAutoLogin"
$LoginScriptPath = if ($LoginScriptPath) { $LoginScriptPath } else {Join-Path (Get-Location) -ChildPath "login.ps1"}

# If not running as administrator, relaunch the script with elevated privileges
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if (-not (Test-Administrator)) {
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Username `"$Username`" -Password `"$Password`" -LoginScriptPath `"$LoginScriptPath`""
    $newProcess = Start-Process powershell -ArgumentList $argList -Verb RunAs -PassThru
    $newProcess.WaitForExit()
    exit
}

if(Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue){
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

<#
Bascially registers a trigger using schtasks with the following parameters:
Logs = Microsoft-Windows-NetworkProfile/Operational 
    Source = Microsoft-Windows-NetworkProfile
    event = 10000 (which is network event for network profile changed)
#>
$taskCommand = @"
schtasks /create /tn $taskName /tr `"powershell.exe -NoProfile -ExecutionPolicy Bypass -File $LoginScriptPath -Username $username -Password $password`" /sc onevent /ec Microsoft-Windows-NetworkProfile/Operational /mo "*[System[Provider[@Name='Microsoft-Windows-NetworkProfile'] and (EventID=10000)]]" /ru SYSTEM /rl HIGHEST
"@
Invoke-Expression $taskCommand

# By deafult only works when connected to AC power. So gotta change that
$task = Get-ScheduledTask -TaskName $taskName
$settings = $task.Settings
$settings.DisallowStartIfOnBatteries = $false
$settings.StopIfGoingOnBatteries = $false
Set-ScheduledTask -TaskName $taskName -Settings $settings
