﻿$Logfile = "C:\Logs\$($MyInvocation.MyCommand.Name).log"
function LogWrite($logString)
{
   Add-content $Logfile -value $logString 
}
function checkIfFileAlreadyOnFTP ($folder){
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": CHECKING IF FILE IS ON FTP: '<$folder>'")
    $ftpCheckFiles = [System.Net.FtpWebRequest]::Create("ftp://192.168.1.179")
    $ftpCheckFiles.Credentials = New-Object System.Net.NetworkCredential("######","#################")
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

$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$count = 0
$totalSize = 0
LogWrite("-----------------------------------Start-----------------------------------")
LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Script started")

#renaming all files that have a "[" or "]" in the name as powershell is stupid and doesn't like it when uploading files
$dir = @(Get-ChildItem "C:\Users\vm305\Desktop\moviesToUpload" -Directory)
foreach($item in $dir){
    Rename-Item -LiteralPath $item.FullName -NewName ($item.name -replace "[\[\]]",'' `
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
                                                                 ) -ErrorAction Continue
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": RENAMED ITEM: '<$item>'")
}

#script that uploads entire folders and its sub-files
$FromDir_SubDir = @(Get-ChildItem "C:\Users\vm305\Desktop\moviesToUpload" -Directory)
$ftp = "ftp://#############@192.168.1.179/"

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

            Copy-Item $folder.FullName -Destination "T:\Movies\" -Recurse -Force
            LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": COPIED FOLDER to BACKUP DRIVE T:\Movies: '<$($folder.Name)>'")

            foreach($file in $files){
                $webclient = New-Object -TypeName System.Net.WebClient
                $uri = New-Object -TypeName System.Uri -ArgumentList "$ftp2/$($file.Name)"

                $webclient.UploadFile("$uri", $file.FullName)
                LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": SUCCESSFULLY UPLOADED FILE to FTP: '<$($file)>' to folder: '<$folder>'")
                #Send-MailMessage -SmtpServer '####' -To @("#####") -From '######' -Subject 'New Movie Uploaded!' -Body "Following movie has been uploaded: $($file.Name)"
                $creds = new-object -typename System.Management.Automation.PSCredential -argumentlist "#####",(Get-Content "C:\Users\vm305\Desktop\Scripts1\cred.txt" | ConvertTo-SecureString)
                Invoke-Command -ComputerName '192.168.1.179' -ScriptBlock {Send-MailMessage -SMTPServer '####' -To @("#####") -From '#####' -Subject 'New Movie Uploaded!' -Body "Following movie has been uploaded: '<$folder>'"} -Credential $creds
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
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + "ERROR OCCURRED: $_.Exception.Message")
}


#script that uploads only files and no subfolders
$FromDir = Get-ChildItem "C:\Users\vm305\Desktop\moviesToUpload" -File
$ftp = "ftp://#################@192.168.1.179/"

Try{
    foreach ($file in $FromDir){

        if ((checkIfFileAlreadyOnFTP -folder $file) -eq $true){
            LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": FILE ALREADY ON FTP...SKIPPING AND REMOVING '<$file>'")
            rmdir $file.FullName -Force -Recurse
            continue
        }else{
            Copy-Item $file.fullname -Destination "T:\Movies" -Force
            LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": COPIED FILE to BACKUP drive: '<$($file.Name)>'")
 
            $ftp1 = $ftp + "/$($file.Name)"
   
            $webclient = New-Object -TypeName System.Net.WebClient
            $uri = New-Object -TypeName System.Uri -ArgumentList $ftp1

            LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": SUCCESSFULLY UPLOADED FILE to FTP: <$($file)>")
            $webclient.UploadFile($uri, $file.FullName)

            $count += 1
            #Send-MailMessage -SmtpServer '#######' -To @("###########") -From 'Plex@ESXI-Plex.com' -Subject 'New Movie Uploaded!' -Body "Following movie has been uploaded: $($file.Name)"
            $creds = new-object -typename System.Management.Automation.PSCredential -argumentlist "####",(Get-Content "C:\Users\vm305\Desktop\Scripts1\cred.txt" | ConvertTo-SecureString)
            Invoke-Command -ComputerName '192.168.1.179' -ScriptBlock {Send-MailMessage -SMTPServer '######' -To @("#######") -From '######' -Subject 'New Movie Uploaded!' -Body "Following movie has been uploaded: '<$folder>'"} -Credential $creds
            Remove-Item $file.FullName
        }
    }
}
Catch{
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": ERROR OCCURRED: $_.Exception.Message")
}

$stopwatch.Stop()
LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Uploaded <$($count)> items in <$($stopwatch.Elapsed.TotalSeconds)> seconds of size <$($totalSize)> MB at avg speed of <$($totalSize/$stopwatch.Elapsed.TotalSeconds)> MB/s")
LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Script ended")
LogWrite("------------------------------------End------------------------------------")
