param (
    [Parameter(Position=1, Mandatory=$true)] [string] $server
#    [Parameter(Position=2, Mandatory=$true)] [string] $database
)

Import-Module Import-Module (join-path $PSScriptRoot LogWriter)

Initialize-Log -counters 'BackUpCount'

$jobsSinceYesterday = @(Get-SqlAgentJobHistory -serverinstance $server -since 'yesterday' | Where {$_.JobName -like '*backup' -and $_.StepID -eq '0'}) #| Out-GridView 

$masterList = @(Get-SqlAgentJobHistory -serverinstance 'srvnj62' | Where {$_.JobName -like '*backup'} | select-object JobName -Unique)

#this gets the all the unique clients from the SQLAgentJobHistory (given that they are named as follows: Client_Type_Backup)
$masterList1 = @()
try{
    for($i = 0; $i -lt $masterList.Length; $i++){
        if($masterList[$i].JobName -imatch '\w*(?=_\w*_\w*)'){
            $masterList1 += $Matches[0]
        }
    }
}
catch{
    Write-Log $_.Exception.Message -Level Error -SummaryKey "Script_Error"
}

$masterList1 = $masterList1 | select -Unique
try{
    if($jobsSinceYesterday.Count -le 0){
        Write-Log "No jobs since yesterday recorded by SqlAgentJobHistory" -Level Error   
    }else{
        for($i = 0; $i -lt $jobsSinceYesterday.Length; $i++){
            #check to see if the latest backup is in a masterlist of clients that should have a backup taken
            if(!(($jobsSinceYesterday[$i].JobName) -notin $masterList.JobName) -and $jobsSinceYesterday[$i].Message -like "*failed*") {
                Write-Log "No Backup for $($jobsSinceYesterday[$i].JobName) or job failed on $($jobsSinceYesterday[$i].RunDate)" -Level Error -SummaryKey $jobsSinceYesterday[$i].JobName
                #Write-Host "No Backup for $($jobsSinceYesterday[$i].JobName)"
            }
            else{
                Write-Log "Found backup taken within 1 day $($jobsSinceYesterday[$i].JobName)" -SummaryKey $jobsSinceYesterday[$i].JobName -SummaryCounter 'BackUpCount'
                #Write-Host "Found backup taken within 1 day $($jobsSinceYesterday[$i].JobName)"
            }
        }
    }
}catch{
    Write-Log "Unhandled failure: $($_.Exception)" -Level Error -SummaryKey "Script_Error"
}
finally{
    Send-LogSummary
}

#($jobsSinceYesterday[0].JobName) -notin ($masterList1[0] | Where-Object {$_ -like "$masterList1[0]_*_Backup"} )
#if(($jobsSinceYesterday[$i].JobName -like "$masterList1[$i]*" ) -notin $masterList1){ #-and check to see if the physical file exists
#"$($jobsSinceYesterday[0].JobName)" -like "$($masterList1[0])*"