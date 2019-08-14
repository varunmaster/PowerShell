$LogFile =  (Join-Path $env:LOGFILE -ChildPath "$($MyInvocation.MyCommand.Name).log")
$movieList = @(gci -Path 'C:\Data\Movies' -Directory | ? {$_.CreationTime.ToString("MM/dd/yyyy") -gt ((Get-Date).AddDays(-7).ToString("MM/dd/yyyy"))}).Name
$token = Get-Content (join-path $env:USERPATH -childpath "/token.txt")
$url = "http://www.omdbapi.com/?apikey=$($token)&"
$movieListEmail = "<h1>Movies:</h1><br/><br/>"
$movieListEmail += "<table style=`"width:100%`">"
$movieCnt=0

function LogWrite($logString)
{
   Add-content $Logfile -value ((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": $logString ")
}

function getName($movie){
    $name = $movie.split(" ") 
    $name1 = (($name[0..($name.Length - 2)]) -join " ") -replace " ","+"
    return $name1
}

function getYear($movie){
    $year = ([regex]::Matches("$movie",'([0-9]{4})')).Value
    return $year
}

function uriBuilder($name){
    $movieName=getName($name)
    $year=getYear($name)
    $uri = $url+"t="+$movieName+"&y="+$year
    return $uri
}

foreach($movie in $movieList){
    $movieCnt++
    if($movieCnt -gt 1 -and $movieCnt%5 -eq 0){
        LogWrite("Already sent 5 API requests...Sleeping for 30 seconds")
        Start-Sleep -Seconds 30
    }else {
        LogWrite("Currently on movie number $($movieCnt) - $($movie) <--> Params:")
        LogWrite(getName($movie))
        LogWrite(getYear($movie))
        $result = Invoke-RestMethod -Method Get -Uri "$url+uriBuilder($movie)"
        LogWrite("Sending API GET...URI is")
        LogWrite(uriBuilder($movie)) 
        if($result.Response -ne "True"){
            LogWrite("Could not get info...trying next movie")
            continue
        }else {
            LogWrite("Got response...retrieving info")
            $movieListEmail += "<tr><td><img src=`"$($result.Poster)`"</td>"
            $movieListEmail += "<td><li>$($result.Title) ($($result.Year))</li>"
            $movieListEmail += "<td><li><i>Released:</i> $($result.Released)</li>"
            $movieListEmail += "<td><li><i>Runtime:</i> $($result.Runtime)</li>"
            $movieListEmail += "<td><li><i>Actors:</i> $($result.Actors)</li>"
            $movieListEmail += "<td><li><i>Plot:</i> $($result.Plot)</li>"
        }
    }
}

$movieListEmail += "</tr></table><br/><br/>"

Send-MailMessage -SMTPServer '###' -To @('###') -From '###' -Subject "Library Updates this week" -Body $movieListEmail -BodyAsHtml
LogWrite("EMAIL SENT")
