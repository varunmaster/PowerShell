<#
    The parameter database does not apply as of right now because the $query is based on the server. This means that no matter what database you put, 
    SSMS will create entry in the msdb.dbo.backupset across ALL databases on particular server.
#>

param (
    [Parameter(Position=1, Mandatory=$true)] [string] $server,
    [Parameter(Position=2, Mandatory=$true)] [string] $database
)

Import-Module -Name C:\Users\vmaster\Desktop\LogWriter.psm1 

Initialize-Log -counters 'BackUpCount'

#find the backups of PROD DB's within last 1 day
$query = "SELECT `
s.database_name, `
CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS bkSize, `
CAST(DATEDIFF(second, s.backup_start_date, `
s.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' TimeTaken, `
s.backup_start_date, `
--CAST(s.first_lsn AS VARCHAR(50)) AS first_lsn, `
--CAST(s.last_lsn AS VARCHAR(50)) AS last_lsn, `
CASE s.[type] `
WHEN 'D' THEN 'Full' `
WHEN 'I' THEN 'Differential' `
WHEN 'L' THEN 'Transaction Log' `
END AS BackupType, `
s.server_name, `
s.recovery_model `
FROM msdb.dbo.backupset s `
WHERE s.database_name like '%Prod' -- Remove this line for all the databases `
and s.backup_start_date between CONVERT(Date,DATEADD(DAY, -1, GETDATE())) and GETDATE() `
--and s.[type] <> 'L' `
ORDER BY backup_start_date DESC `
GO"

$ClientBackup = @('SSI_Prod', 'ACME_Prod', 'ACMEFIN_Prod')

$getBackupStatus = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query $query | Out-File C:\Users\vmaster\Desktop\something.txt -NoClobber utf8 -Append 

for($i = 0; $i -lt $getBackupStatus.Length; $i++){
    #check to see if the latest backup is in a masterlist of clients that should have a backuptaken
    if($getBackupStatus[$i][0] -notin $ClientBackup ){ #-and check to see if the physical file exists
        Write-Log "No Backup for" + $getBackupStatus[$i][0] -Level Error -SummaryKey $getBackupStatus[$i][0]
        #Write-Host $getBackupStatus[$i][0]
    }
    else{
        Write-Log 'Found backup taken within 1 day' -SummaryKey $getBackupStatus[$i][0] -SummaryCounter 'BackUpCount'
    }
}

Write-LogSummary
#Send-LogSummary