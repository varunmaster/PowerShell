$LogFile = (Join-Path $env:LOGFILE -ChildPath "$($MyInvocation.MyCommand.Name).log")
$movieList = @(gci -Path 'C:\Data\Movies' -Directory | ? {$_.CreationTime.ToString("MM/dd/yyyy") -gt ((Get-Date).AddDays(-7).ToString("MM/dd/yyyy"))}).Name
$token = Get-Content (join-path $env:USERPATH -childpath "/token.txt")
$url = "http://www.omdbapi.com/?apikey=$($token)&t="
$movieListEmail = "<h1>Movies:</h1><br/><br/>"
$movieListEmail += "<table style=`"width:100%`">"
$movieCnt=0
$global:getNameFromFunc
$global:getYearFromFunc

function LogWrite($logString)
{
   Add-content $Logfile -value ((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": $logString ")
}

function getName($movie){
    $name = $movie.split(" ") 
    $name1 = (($name[0..($name.Length - 2)]) -join " ") -replace " ","+"
    $global:getNameFromFunc = $name1
    return $global:getNameFromFunc
}

function getYear($movie){
    $year = ([regex]::Matches("$movie",'([0-9]{4})')).Value
    $global:getYearFromFunc = $year
    return $global:getYearFromFunc
}

foreach($movie in $movieList){
    $movieCnt++
    if($movieCnt -gt 1 -and $movieCnt%5 -eq 0){
        LogWrite("Already sent 5 API requests...Sleeping for 30 seconds")
        Start-Sleep -Seconds 30
    }else {
        LogWrite("Currently on movie number $($movieCnt) - $($movie) <--> Params:")
        #LogWrite(getName($movie))
        #LogWrite(getYear($movie))
        getName($movie)
        getYear($movie)
        $result = Invoke-RestMethod -Method Get -Uri ("$url$($global:getNameFromFunc)"+"&y=$($global:getYearFromFunc)")
        
        LogWrite("$url$($global:getNameFromFunc)"+"&y=$($global:getYearFromFunc)")
        LogWrite("Result is:\n"+$result)
        
        if($result.Response -ne "True"){
            LogWrite("Could not get info...trying next movie")
            continue
        }else {
            LogWrite("Got response...retrieving info")
            $movieListEmail += "<tr><td><img src=`"$($result.Poster)`"></td>"
            $movieListEmail += "<td><li>$($result.Title) ($($result.Year))</li>"
            $movieListEmail += "<li><b>Released:</b> $($result.Released)</li>"
            $movieListEmail += "<li><b>Runtime:</b> $($result.Runtime)</li>"
            $movieListEmail += "<li><b>Actors:</b> $($result.Actors)</li>"
            $movieListEmail += "<li><b>Plot:</b> $($result.Plot)</li>"
            $movieListEmail += "<li>------------------------------------------------------------------------------</li>"
            $movieListEmail += "</td></tr>"
            LogWrite($movieListEmail)
        }
    }
}

$movieListEmail += "</table><br/><br/>"
#LogWrite($movieListEmail)
Send-MailMessage -SMTPServer '###' -To @('###') -From '###' -Subject "Library Updates this week" -Body $movieListEmail -BodyAsHtml
LogWrite("EMAIL SENT")
