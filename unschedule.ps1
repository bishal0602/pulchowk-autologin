function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if (-not (Test-Administrator)) {
    $argList = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    $newProcess = Start-Process powershell -ArgumentList $argList -Verb RunAs -PassThru
    $newProcess.WaitForExit()
    exit
}

$taskName = "PulchowkWifiAutoLogin"
if(Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue){
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
    Write-Host "$taskName unscheduled successfully!" -ForegroundColor Green
}
else{
    Write-Host "$taskName doesn't exist!" -ForegroundColor Red
}
