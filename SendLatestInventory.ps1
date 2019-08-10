function getLatestMovies($prevDays){
    gci -Path 'C:\Data\Movies' -Directory | ? {$_.CreationTime.ToString("MM/dd/yyyy") -le ((Get-Date).AddDays(-$prevDays).ToString("MM/dd/yyyy"))}
}

Invoke-RestMethod -Method Get 
