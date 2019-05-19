param(
    [Parameter(Mandatory = $false,HelpMessage="What you want to rename comp to")][String] $hostName,
    [Parameter(Mandatory = $false,HelpMessage="What you want ip to be")][String] $ip,
    [Parameter(Mandatory = $false,HelpMessage="Repoint to 192.168.1.166")] $DNS,
#    [Parameter(Mandatory = $true)][String] $ipMode,
    [Parameter(Mandatory = $false,HelpMessage="Name of rule, e.g. Allow My Rules")][String] $firewallRuleName,
    [Parameter(Mandatory = $false,HelpMessage="The port numbers: 25,587,32400,8080,8085")] $firewallRulePort
)

