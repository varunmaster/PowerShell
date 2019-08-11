function getLatestMovies($prevDays){
    gci -Path 'C:\Data\Movies' -Directory | ? {$_.CreationTime.ToString("MM/dd/yyyy") -le ((Get-Date).AddDays(-$prevDays).ToString("MM/dd/yyyy"))}
}

$token = Get-Content "C:\Users\vm305\Desktop\Scripts1\token.txt"
$url = "http://www.omdbapi.com/?apikey=$($token)&"

Invoke-RestMethod -Method Get -Uri $url+"t="$name+"&y="$year
