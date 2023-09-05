$Logfile = "C:\Logs\$($MyInvocation.MyCommand.Name).log"
function LogWrite($logString) {
    Add-content $Logfile -value "$($(Get-Date).toString('yyyy/MM/dd HH:mm:ss')): $logString"
}
LogWrite("#######################           Start         #######################")
$currList = @(Get-Content -Path "C:\Data\Movies\_movieList.txt")
LogWrite("Got List of current movies in inventory from master list")
[String[]] $getMovieFromLast10Mins = @((Get-ChildItem -Path "C:\Data\Movies" -Directory | ? { $_.LastWriteTime -ge ((Get-Date) - (New-TimeSpan -Minutes 10)) }).Name)
LogWrite("Got list of movies that are from the last 10 mins")
$movieListToSend = @()
$movieCount = 0
$movieListToSendHtml = "<ul> </br>"
$uri = "http://www.omdbapi.com/?apikey=$($env:OMDBAPITOKEN)&t="

foreach($movie in $getMovieFromLast10Mins) {
    if ($movie -notin $currList -and $movie.Length -gt 0) {
        $movieListToSend += $movie
        $movieCount++
        LogWrite("Movie not in inventory: <$movie>")
    } else {
        continue
    }
}

foreach($movieName in $movieListToSend) {
    $uri += ("$($([regex]::Match($movieName,"(?<=)(.*)(.+?(?=\s\(\d{4}\)))").Value))").replace(' ','+')
    LogWrite("Found movie name with REGEX: <$(("$($([regex]::Match($movieName,"(?<=)(.*)(.+?(?=\s\(\d{4}\)))").Value))").replace(' ','+'))>")
    $uri += "&y=$($([regex]::Match($movieName,"(?<=\()(\d{4})(?=\))").Value))"
    LogWrite("Found movie year with REGEX: <$("$($([regex]::Match($movieName,"(?<=\()(\d{4})(?=\))").Value))")>")
    $result = Invoke-RestMethod -Method Get -Uri $uri
    #LogWrite("URI to be used: $uri")
    LogWrite("Found the imdbID from API call: <$($result.imdbID)>")
    $movieListToSendHtml += "<li> <a href='https://www.imdb.com/title/" + $result.imdbID + "' target = _blank>" + $movieName + "</a> </li> </br>"
    LogWrite("Created link for movie: <li> <a href='https://www.imdb.com/title/" + $result.imdbID + "' target = _blank>" + $movieName + "</a> </li> </br>")
}

$movieListToSendHtml += "</ul>"
if ($movieCount -ne 0) {
    Send-MailMessage -SmtpServer "###" -Bcc ("###") -To ("###") -From ("###") -Subject "New Movie(s) Uploaded!" -Body $movieListToSendHtml -BodyAsHtml
    LogWrite("Sent email")
    (Get-ChildItem -Path C:\Data\Movies -Directory).Name | Out-File -FilePath "C:\Data\Movies\_movieList.txt" #run at end of script to get updated master list
    LogWrite("Generated updated master movie list")
} else {
    LogWrite("No new movies added")
}
LogWrite("#######################           End           #######################")
