[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification='Not sensitive')]
param (
    [Parameter(Mandatory=$true, HelpMessage="Your campus wifi username")]
    [Alias("user")]
    [string]$Username,
    
    [Parameter(Mandatory=$true, HelpMessage="Your campus wifi password")]
    [string]$Password
)

[string[]]$campusWifiSSIDs = @('PC_ELEXCOMP', 'PC-ELEXCOMP', 'CITPC', 'CIT AP') #TODO: Add more SSIDs
function Write-LogFile {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message
    )
    
    $Message | Out-File -FilePath "D:\workspace\WifiAutoLogin\log.txt" -Append
}

function Test-IsCampusWifi {
    $wifiSSID = netsh wlan show interfaces | Select-String -Pattern 'SSID' | Select-Object -First 1
    if($null -eq $wifiSSID){
        return $false
    } 
    $wifiSSID = $wifiSSID.Line.Split(':')[1].Trim()
    $state = (netsh wlan show interfaces | Select-String -Pattern 'State' | Select-Object -First 1).Line.Split(':')[1].Trim()

    Write-LogFile "$wifiSSID $state"

    $SSIDHashSet = [System.Collections.Generic.HashSet[string]]::new(
        $campusWifiSSIDs, 
        [System.StringComparer]::OrdinalIgnoreCase)
    
    [bool]$SSIDHashSet.Contains($wifiSSID)
}
function Invoke-UTMLoginRequest {
    param (
        [string]$Username,
        [string]$Password
    )
    try{
        $url = "https://10.100.1.1:8090/login.xml"
        $headers = @{
            "Host"             = "10.100.1.1:8090"
            "Accept-Encoding"  = "gzip, deflate, br, zstd"
            "Origin"           = "https://10.100.1.1:8090"
            # "Connection"       = "keep-alive"
            "Referer"          = "https://10.100.1.1:8090/httpclient.html"
            "Sec-Fetch-Dest"   = "empty"
            "Sec-Fetch-Mode"   = "cors"
            "Sec-Fetch-Site"   = "same-origin"
            "DNT"              = "1"
            "Sec-GPC"          = "1"
            "User-Agent"       = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:128.0) Gecko/20100101 Firefox/128.0"
            "Accept"           = "*/*"
            "Accept-Language"  = "en-US,en;q=0.5"
            "Content-Type"     = "application/x-www-form-urlencoded"
        } # (adding so much headers for "reasons" :D)

        $bodyParams = [ordered]@{
            mode        = 191 # 191 for login operation
            username    = $Username
            password    = $Password
            a           =  [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds() # Unique session ID
            producttype = 0 # Type of service being accessed
        }

        try {
        # Need this to skip SSL certificate validation in windows powershell version
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
            return true;
        }
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy    
        }
        catch {
            # prolly means already registered or newer powershell version
        }

        $bodyString = ($bodyParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
        try{
            $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $bodyString -ContentType "application/x-www-form-urlencoded" 
        }
        catch{
            Write-LogFile "Request error: Status = $($_.Execption.Status) Message = $($_.Exception.Message)"
        }

        return $response
    }
    catch{
        Write-LogFile "Invoke-UTMLoginRequest error: Status = $($_.Execption.Status) Message = $($_.Exception.Message)"
        return $null
    }
}

$isCampusWifi = Test-IsCampusWifi
Write-LogFile "PulchowkWifiAutoLogin triggered at $(Get-Date) $Username $isCampusWifi"

#Login to UTM server
if($isCampusWifi -eq $false){
    return
}

"D:/workspace/WifiAutoLogin/utm_login/utm_login.exe -username='078BCT036' -password='1234-5678' > D:/workspace/WifiAutoLogin/output.log 2>&1" | Invoke-Expression

# $response = Invoke-UTMLoginRequest -Username $Username -Password $Password
# if($null -eq $response){
#     return
# }
# $response_string = $response.OuterXml.ToString()
# Write-LogFile "Log in response at $(Get-Date) $response_string"