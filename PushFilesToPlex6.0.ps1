﻿$Logfile = "C:\Logs\$($MyInvocation.MyCommand.Name).log"
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$count = 0
$totalSize = 0
$movieEmailList = @()
$token = Get-Content $env:OMDBAPITOKEN
$url = "http://www.omdbapi.com/?apikey=$($token)&t="
function LogWrite($logString)
{
   Add-content $Logfile -value $logString 
}
LogWrite("`
#######################################################################`
######################           Start           ######################`
#######################################################################`
")
LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Script started")

function checkIfFileAlreadyOnFTP ($folder){
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

function movieNameAndYearSplit ($movieName) {
    $nameAndYear = @()
    $nameAndYear += ("$([regex]::Match("$movieName","(?<=\<li\>)(.*)(.+?(?=\s\(\d{4}\)))").Value)") #matching name only
    $nameAndYear += ("$([regex]::Match("$movieName","(?<=\()(\d{4})(?=\))").Value)") #matching year only
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Split Name and Year: '<$nameAndYear>'")
    return $nameAndYear
}

function callAPIReturnImdb($name) {
    $val = movieNameAndYearSplit($name)
    $uri = $url + "$($val[0])&y=$($val[1])"
    $result = Invoke-RestMethod -Method Get -Uri $uri
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Made API call and return imdbID: '<$($result.imdbID)>'")
    return "https://www.imdb.com/title/" + $result.imdbID + "/"
}

function sendEmail ($movieEmailList){
    $movieLink = @()
    $movieLinkHtml = @()
    $movieEmailList.ForEach({
        $val = movieNameAndYearSplit($_)
        $link = callAPIReturnImdb($_)
        #$movieLink += $link
        $movieLinkHtml += "<li><a href='" + $link + "' target=_blank>" + $val[0] + " ($($val[1]))" + "</a></li>"
    })
    #Write-Host $movieLinkHtml
    $pw = '###' | ConvertTo-SecureString -Force -AsPlainText
    $creds = New-Object System.Management.Automation.PsCredential("###", $pw)
    $scriptBlock = {
        $server = '###'
        $to = @("###")
        $from = '###'
        $sub = 'New Movie Uploaded'
        $body = "Movie(s) uploaded: <ul> </br>" + $args + "</ul>" #$movieLinkHtml + "</ul>" 

        Send-MailMessage -SMTPServer $server -To $to -From $from -Subject $sub -Body $body -BodyAsHtml
    }
    Invoke-Command -ComputerName '###' -ScriptBlock $scriptBlock -Credential $creds -ArgumentList ($movieLinkHtml)
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": EMAIL SENT")
    #thanks to ralphkyttle = https://blogs.technet.microsoft.com/ralphkyttle/2015/06/04/powershell-passing-parameters-as-variables-using-remote-management-and-invoke-command/
}

#renaming all files that have a "[" or "]" in the name as powershell is stupid and doesn't like it when uploading files
$dir = @(Get-ChildItem "C:\Users\vm305\Desktop\moviesToUpload" -Directory)
Try{
    foreach($item in $dir){
        Rename-Item -LiteralPath $item.FullName -NewName ($item.name -replace "\.",' '`
                                                                     -replace "(?<=\(\d{4}\))(.*)",''`
                                                                     -replace "[\[\]]",'' `
                                                                     -replace "1080p",'' `
                                                                     -replace "1080",'' `
                                                                     -replace "webrip",'' `
                                                                     -replace "bluray",'' `
                                                                     -replace "yts.am",'' `
                                                                     -replace "yify",'' `
                                                                     -replace "rar.bg",'' `
                                                                     -replace "x264",'' `
                                                                     -replace "yts.ag",'' `
                                                                     -replace "720p",'' `
                                                                     -replace "720",'' `
                                                                     -replace "yts.lt",'' `
                                                                     -replace "   H264 AAC-RARBG",''`
                                                                     ) -ErrorAction Continue
        LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": RENAMED ITEM: '<$item>'")
    }
}
Catch{
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": ERROR OCCURRED: $_.Exception.Message")
}

#script that uploads entire folders and its sub-files
$FromDir_SubDir = @(Get-ChildItem "C:\Users\vm305\Desktop\moviesToUpload" -Directory)
$ftp = "ftp://###:###@###/"

Try{
    foreach ($folder in $FromDir_SubDir){
        $ftp2 = $ftp + "/$folder"
        $files = @(Get-ChildItem $folder.FullName -Recurse -File)
    
        if ((checkIfFileAlreadyOnFTP -folder $folder) -eq $true){
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
            $movieEmailList += "<li>" + $folder.Name + "</li>"

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
}
Catch{
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": ERROR OCCURRED: $_.Exception.Message")
}

if ($movieEmailList.Length -ne 0){
    sendEmail($movieEmailList)
}

$stopwatch.Stop()
LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Uploaded <$($count)> items in <$($stopwatch.Elapsed.TotalSeconds)> seconds of size <$($totalSize)> MB at avg speed of <$($totalSize/$stopwatch.Elapsed.TotalSeconds)> MB/s")
LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Script ended")
LogWrite("`
#######################################################################`
#######################           End           #######################`
#######################################################################")
