function getName ($movie){
    $name = ([regex]::Matches("$movie.Name",'[a-zA-Z]+\s\d?')).Value[0] #wholeword,space,optional number
    return $name
}

function getYear ($movie){
    $year = ([regex]::Matches("$movie.Name",'([0-9]{4})')).Value
    return $year
}

$movieList = @(gci -Path 'C:\Data\Movies' -Directory | ? {$_.CreationTime.ToString("MM/dd/yyyy") -le ((Get-Date).AddDays(-$prevDays).ToString("MM/dd/yyyy"))}).Name
$token = Get-Content "/Users/varun/Desktop/token.txt"
$url = "http://www.omdbapi.com/?apikey=$($token)&"
$movieListEmail = "<h1>Movies:</h1><br/><br/>"
$movieListEmail += "<table style=`"width:100%`">"
$movieCnt=0

foreach($movie in $movieList){
    $movieCnt++
    if($movieCnt -gt 1 -and $movieCnt%5 -eq 0){
        Start-Sleep -Seconds 30
    }else {
        $result = Invoke-RestMethod -Method Get -Uri $url+"t="getName($movie)+"&y="getYear($movie)
        $movieListEmail += "<tr><td><img src=`"$($result.Poster)`"</td>"
        $movieListEmail += "<td><li>$($result.Title) ($($result.Year))</li>"
        $movieListEmail += "<td><li><i>Released:</i> $($result.Released)</li>"
        $movieListEmail += "<td><li><i>Runtime:</i> $($result.Runtime)</li>"
        $movieListEmail += "<td><li><i>Actors:</i> $($result.Actors)</li>"
        $movieListEmail += "<td><li><i>Plot:</i> $($result.Plot)</li>"
    }
}

$movieListEmail += "</tr></table><br/><br/>"

Send-MailMessage -SMTPServer '###' -To @('###') -From '###' -Subject "Library Updates this week" -Body $movieListEmail -BodyAsHtml