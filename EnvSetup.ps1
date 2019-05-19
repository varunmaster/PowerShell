param(
    [Parameter(Mandatory = $false,HelpMessage="What you want to rename comp to")][String] $hostName,
    [Parameter(Mandatory = $false,HelpMessage="What you want ip to be")][String] $ip,
    [Parameter(Mandatory = $false,HelpMessage="Repoint to 192.168.1.166")] $DNS,
#    [Parameter(Mandatory = $true)][String] $ipMode,
    [Parameter(Mandatory = $false,HelpMessage="Name of rule, e.g. Allow My Rules")][String] $firewallRuleName,
    [Parameter(Mandatory = $false,HelpMessage="The port numbers: 25,587,32400,8080,8085")] $firewallRulePort
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
            LogWrite("IP changed")
            #New-NetIPAddress -IPAddress $ip -InterfaceAlias 'Ethernet0' -PrefixLength 24 -DefaultGateway 192.168.1.1
        }else {
            LogWrite("Current IP is: $($ipOld) and new IP is : $($ip). Nothing changed")
        }
    }
    catch{
        LogWrite($_.Exception.Message)
    }
}

function changeDNS (){
    try{
        if (!$DNS){
            LogWrite("DNS changed")
            #Set-DnsClientServerAddress -ServerAddresses 192.168.1.166, 8.8.8.8 
        }
        else {
            Write-Host "enter 'pihole' as the DNS parameter"
        }
    }
    catch{
        LogWrite($_.Exception.Message)
    }
}

function firewallRules($name, $port){
    try{
        LogWrite("firewall rule changed")
        #New-NetFirewallRule -DisplayName $name -Direction Inbound -LocalPort $port -Protocol TCP -Action Allow -Group 
    }
    catch{
        LogWrite($_.Exception.Message)
    }
}

function renameComputer ($newName){
    try{
        LogWrite("computer name changed")
        #Rename-Computer -NewName $hostName 
    }
    catch{
        LogWrite($_.Exception.Message)
    }
}

if(!$ip){
    changeIP -ip $ip
}else{
    continue
}
if(!$DNS){
    changeDNS
}else{
    continue
}
if(!$firewallRuleName){
    firewallRules -name $firewallRuleName -port $firewallRulePort
}else{
    continue
}
if (!$firewallRulePort) {
    renameComputer -newName $hostName 
}else{
    continue
}
Read-Host "tea;lst"
