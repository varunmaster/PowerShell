$Logfile = "C:\Logs\$($MyInvocation.MyCommand.Name).log"
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$count = 0
$totalSize = 0
$url = "http://www.omdbapi.com/?apikey=$($env:OMDBAPITOKEN)&t="
function LogWrite {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$logString
    )
   Add-content $Logfile -value $logString 
   Write-Host $logString
}
LogWrite("`
#######################################################################`
######################           Start           ######################`
#######################################################################`
")
LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Script started")

function checkIfFileAlreadyOnFTP {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$folder
    )
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": CHECKING IF FILE IS ON FTP: '<$folder>'")
    $ftpCheckFiles = [System.Net.FtpWebRequest]::Create("ftp://###")
    $ftpCheckFiles.Credentials = New-Object System.Net.NetworkCredential("###","###")
    $ftpCheckFiles.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $ftpCheckFiles.GetResponse()
    $ftpGR = $ftpCheckFiles.GetResponse()
    $rs = $ftpGR.GetResponseStream()
    $StreamReader = New-Object System.IO.Streamreader $rs
    $filesOnFtp = @($StreamReader.ReadToEnd() -split [Environment]::NewLine) #this puts all the files in an array 
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": CLOSING FTP CONNECTION")
    $ftpGR.Close()

    if($filesOnFtp -contains $folder){
        return $true
    }else {
        return $false
    }
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": FINISHED CHECKING IF ON FTP")
}

function movieNameAndYearSplit {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$movieName
    )
    $nameAndYear = @()
    $nameAndYear += ("$([regex]::Match("$movieName","(.*)(?=(\s\(\d{4}\)))").Value)") #matching name only
    $nameAndYear += ("$([regex]::Match("$movieName","(?<=\()\d{4}(?=\))").Value)") #matching year only
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Split Name and Year: '<$nameAndYear>'")
    return $nameAndYear
}

function callAPIReturnImdb {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$name
    )
    $val = movieNameAndYearSplit $name
    $uri = $url + "$($val[0])&y=$($val[1])"
    $result = Invoke-RestMethod -Method Get -Uri $uri
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Made API call and return imdbID: '<$($result.imdbID)>'")
    #return "https://www.imdb.com/title/" + $result.imdbID + "/"
    return $result.imdbID
}

function sendEmail {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$movieList
    )
    
    $body = "<ul> </br>"
    foreach ($movie in $movieList) {
        $movieImdbID = callAPIReturnImdb $movie
        $body += "<li> <a href='https://www.imdb.com/title/" + $movieImdbID + "' target = _blank>" + $movie + "</a> </li> </br>"
    }
    $body += "</ul>"
    
    Send-MailMessage -SmtpServer "ESXi-WinMail" -Bcc ("###") -To ("###") -From ("###") -Subject "New Movie(s) Uploaded!" -Body $body -BodyAsHtml
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": EMAIL SENT")
}

#renaming all files that have a "[" or "]" in the name as powershell is stupid and doesn't like it when uploading files
$dir = @(Get-ChildItem "F:\FrostWire\FrostWire 6\Data" -Directory)
Try{
    foreach($item in $dir){
        Rename-Item -LiteralPath $item.FullName -NewName ($item.name -replace "\.",' '`
                                                                     -replace "(?<=\(\d{4}\))(.*)",''`
                                                                     -replace "[\[\]]",'' `
                                                                     -replace "   H264 AAC-RARBG",''`
                                                                     ) -ErrorAction Continue
        LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": RENAMED ITEM: '<$item>'")
    }
}
Catch{
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": ERROR OCCURRED: $_.Exception.Message")
}

#script that uploads entire folders and its sub-files
$FromDir_SubDir = @(Get-ChildItem "F:\FrostWire\FrostWire 6\Data" -Directory)
$ftp = "ftp://###"

Try{
    $movieEmailList = @()
    foreach ($folder in $FromDir_SubDir) {
        $ftp2 = $ftp + "/$folder"
        $files = @(Get-ChildItem $folder.FullName -Recurse -File)
    
        if ((checkIfFileAlreadyOnFTP $folder) -eq $true){
            LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": FOLDER ALREADY ON FTP...SKIPPING AND REMOVING '<$folder>'")
            rmdir $folder.FullName -Force -Recurse
            continue
        }else{
            LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": FOLDER NOT ON FTP...UPLOADING '<$folder>'")
            $makeDir = [System.Net.WebRequest]::Create($ftp2)
            #$makeDir.Credentials = New-Object System.Net.NetworkCredential($user,$pass)
            $makeDir.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory
            $makeDir.GetResponse()
            LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": CREATED FOLDER ON FTP: <$folder>")
            $movieEmailList += $folder.Name

            Copy-Item $folder.FullName -Destination "T:\Movies\" -Recurse -Force
            LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": COPIED FOLDER to BACKUP DRIVE T:\Movies: '<$($folder.Name)>'")

            foreach($file in $files){
                $webclient = New-Object -TypeName System.Net.WebClient
                $uri = New-Object -TypeName System.Uri -ArgumentList "$ftp2/$($file.Name)"

                $webclient.UploadFile("$uri", $file.FullName)
                LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": SUCCESSFULLY UPLOADED FILE to FTP: '<$($file)>' to folder: '<$folder>'")
                $count += 1
                $totalSize += $file.Length/1MB
                Remove-Item $file.FullName -Recurse -Force 
            }
            rmdir $folder.FullName -Force -Recurse
            $res = $makeDir.GetResponse()
            LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": CLOSING FTP CONNECTION")
            $res.Close()
        }
    }
    if ($movieEmailList.Length -ne 0){
        sendEmail $movieEmailList
    }
}
Catch{
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": ERROR OCCURRED: $_.Exception.Message")
}

$stopwatch.Stop()
LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Uploaded <$($count)> items in <$($stopwatch.Elapsed.TotalSeconds)> seconds of size <$($totalSize)> MB at avg speed of <$($totalSize/$stopwatch.Elapsed.TotalSeconds)> MB/s")
LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Script ended")
LogWrite("`
#######################################################################`
#######################           End           #######################`
#######################################################################")
