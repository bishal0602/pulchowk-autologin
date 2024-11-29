[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification='Not sensitive')]

$goArchMap = @{
    "AMD64" = "amd64"
    "x86" = "386"
    "ARM" = "arm"
    "ARM64" = "arm64"
}
$arch = $goArchMap[$env:PROCESSOR_ARCHITECTURE]
if(-not $arch){
    Write-Host "The architecture $env:PROCESSOR_ARCHITECTURE is not supported." -ForegroundColor Red
    exit 1
}

$schedulerScriptUrl = "http://dist.bishal0602.com.np/pcampus/scheduler.ps1"
$unschedulerScriptUrl = "http://dist.bishal0602.com.np/pcampus/unscheduler.ps1"
$loginExecutableUrl = "http://dist.bishal0602.com.np/pcampus/bin/utm_login-windows-$arch.exe"


function DownloadFile {
    param (
        $sourceUrl,
        $destinationPath
    )
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($sourceUrl, $destinationPath)
        Write-Host "File downloaded successfully to $destinationPath"
        return $true
    }
    catch {
        Write-Host "Failed to download the file $destinationPath`n$_" -ForegroundColor Red
        return $false
    }
    finally {
        if ($webClient) {
            $webClient.Dispose()
        }
    }
}
Clear-Host
Write-Host "Starting PulchowkWifiAutoLogin setup..." -ForegroundColor Cyan
Write-Host "This script will download necessary files and configure auto-login for Pulchowk Campus WiFi." -ForegroundColor Cyan

New-Item PulchowkWifiAutoLogin -ItemType Directory -Force | Out-Null
$rootDir = Join-Path (Get-Location) PulchowkWifiAutoLogin

$schdulerScriptPath = Join-Path $rootDir "scheduler.ps1"
$unschedulerScriptPath = Join-Path $rootDir "unscheduler.ps1"
$loginExecutablePath = Join-Path $rootDir "utm_login.exe"

Write-Host "Downloading required files..."
$ok = DownloadFile $schedulerScriptUrl $schdulerScriptPath
if (-not $ok) {
    Write-Host "Exiting...`n"
    return
}
$ok = DownloadFile $unschedulerScriptUrl $unschedulerScriptPath
if (-not $ok) {
    Write-Host "Exiting...`n"
    return
}
$ok = DownloadFile $loginExecutableUrl $loginExecutablePath
if (-not $ok) {
    Write-Host "Exiting...`n"
    return
}
Write-Host "PulchowkWifiAutoLogin downloaded successfully!" -ForegroundColor Green

$Username = Read-Host "`nEnter your campus login username"
$PasswordSecure = Read-Host "Enter your campus login password" -AsSecureString
$Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($PasswordSecure))

$newProcess = $null
$argList = "-NoProfile -ExecutionPolicy Bypass -File `"$schdulerScriptPath`" -Username `"$Username`" -Password `"$Password`" -LoginExectablePath `"$loginExecutablePath`""
try{
    $newProcess = Start-Process powershell -ArgumentList $argList -Verb RunAs -PassThru -ErrorAction Stop
} catch {
    Write-Host "The scheduler could not run because administrator privileges were not granted." -ForegroundColor Yellow
    Write-Host "Please run the script again and allow the prompt for administrator access." -ForegroundColor Yellow
    return
}

if ($null -eq $newProcess) {
    return
}

$newProcess.WaitForExit()
if ($newProcess.ExitCode -eq 0) {
    Write-Host "`nPulchowkWifiAutoLogin has been installed successfully!" -ForegroundColor Green
    Write-Host "Whenever you connect to the campus WiFi, you'll be logged into the campus server automatically." -ForegroundColor Green
    Write-Host "Feel free to close this window now."
    Write-Host "*(^o^)*`n"
} else {
    Write-Host "Oops! something went wrong :( `nExit Code: $($newProcess.ExitCode)." -ForegroundColor Red
}