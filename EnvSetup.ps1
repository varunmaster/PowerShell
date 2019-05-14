param(
    [Parameter(Mandatory = $true)][String] $hostName,
    [Parameter(Mandatory = $false)][String] $ip,
    [Parameter(Mandatory = $true)] $DNS,
#    [Parameter(Mandatory = $true)][String] $ipMode,
    [Parameter(Mandatory = $true)][String] $firewallRuleName,
    [Parameter(Mandatory = $true)] $firewallRulePort
)

$Logfile = "C:\Logs\$($MyInvocation.MyCommand.Name).log"
function LogWrite($logString)
{
   Add-content $Logfile -value $logString 
}

function changeIP ($ip) {
    try {
        $currName = hostname
        $ipOld = Test-Connection -ComputerName $currName -Count 1 | Select-Object IPV4Address

        if ($ipOld -ne $ip) {
            New-NetIPAddress -IPAddress $ip -DefaultGateway 192.168.1.1 -PrefixLength 24
        }else {
            LogWrite("Current IP is: $($ipOld) and new IP is : $($ip). Nothing changed")
        }
    }
    catch{
        LogWrite($_.Exception.Message)
    }
}

function changeDNS ($DNS){
    try{
        Set-DnsClientServerAddress -ServerAddresses 192.168.1.166, 8.8.8.8
    }
    catch{
        LogWrite($_.Exception.Message)
    }
}

function firewallRules($name, $port){
    New-NetFirewallRule -DisplayName $name -Direction Inbound -LocalPort $port -Protocol TCP -Action Allow
}

function renameComputer ($newName){
    Rename-Computer -NewName $hostName
}


changeIP -ip $ip
changeDNS -DNS
firewallRules -name $firewallRuleName -port $firewallRulePort
renameComputer -newName $hostName 
