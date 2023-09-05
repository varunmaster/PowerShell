# Need to have a file called publicIP.txt with only the current IP and in same directory

$Logfile = "C:\Logs\$($MyInvocation.MyCommand.Name).log"
function LogWrite {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$logString
    )
    Add-content $Logfile -value "$($(Get-Date).toString('yyyy/MM/dd HH:mm:ss')): $logString"
}

# a quick Get method to get current subdomains
# $headers = @{}
# $headers.Add("Content-Type", "application/json")
# $headers.Add("X-Auth-Email", "v***@gmail.com")
# $headers.Add("X-Auth-Key", "global_api_key")
# $response = Invoke-RestMethod -Uri 'https://api.cloudflare.com/client/v4/zones/####/dns_records' -Method GET -Headers $headers
# Write-Host $response.result
# ############################ --> global API key
# ############################ --> Edit dns zone settings, dont think this is used for this API call
function updateCFIP() {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, HelpMessage = "The new IP for all the DNS entries in the zone")]
        [string]$newIP
    )
    $subDomains = @{
        'grafana.varunmaster.com'   = '####';
        'inventory.varunmaster.com' = '####';
        'plex.varunmaster.com'      = '####';
        '@'                         = '####';
        #'test.varunmaster.com'     = '####';
    }
    $headers = @{}
    $headers.Add("Content-Type", "application/json")
    $headers.Add("X-Auth-Email", "v***@gmail.com")
    $headers.Add("X-Auth-Key", "####")
    foreach ($subDomain in $subDomains.GetEnumerator()) {
        $body = @{
            'content' = "$newIP";
            'name'    = "$($subDomain.Name)";
            'proxied' = $True;
            'type'    = 'A';
            'comment' = "Updated from script";
            'ttl'     = '1';
        } | ConvertTo-Json
        LogWrite -logString "Going to update the IP for subdomain $($subDomain.Name) with new value of $($newIP)"
        $response = Invoke-WebRequest -Uri "https://api.cloudflare.com/client/v4/zones/####/dns_records/$($subDomain.Value)" -Method PUT -Headers $headers -ContentType 'application/json' -Body $body
        if ($response.StatusCode -ne 200) {
            LogWrite -logString "-----------------Error with API from CloudFlare-----------------"
            LogWrite -logString "Failure...response from CloudFlare API: $($Error[0])"
            LogWrite -logString "----------------->>>>>>>End<<<<<<<-----------------"
        }
        else {
            LogWrite -logString "Successful update of the subdomain"
            LogWrite -logString "Going to update the next subdomain...if there are any"
        }
        Start-Sleep 5
    }
}

$savedPubIP = (Get-Content C:\Scripts\publicIP.txt).ToString() # Tried to use Resolve-DnsName but we have proxy enabled in CF for the zone so we won't have real IP
[string]$currPubIP = Invoke-WebRequest -Uri 'https://ifconfig.me/ip'

if ($currPubIP -ne $savedPubIP) {
    LogWrite("######################  Start  ######################")
    LogWrite -logString "IPs do not match: Saved <$savedPubIP> and curr <$currPubIP>"
    LogWrite -logString "Calling function to update the IP on CloudFlare"
    updateCFIP -newIP $currPubIP
    LogWrite -logString "Updating the publicIP.txt file with the new IP of <$currPubIP>"
    Set-Content -Value $currPubIP -Path C:\Scripts\publicIP.txt 
    LogWrite -logString "Script finished...peace out girl scout."
}
else {
    LogWrite -logString "Current and public IPs are match...nothing to do...peace out girl scout."
}
