$Logfile = "C:\Users\vm305\Desktop\Logs\$($MyInvocation.MyCommand.Name).log"
function LogWrite($logString)
{
   Add-content $Logfile -value $logString
}

LogWrite("-----------------------------------Start-----------------------------------")
LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Script started")


#renaming all files that have a "[" or "]" in the name as powershell is stupid and doesn't like it when uploading files
$dir = @(Get-ChildItem "C:\Users\vm305\Desktop\moviesToUpload" -Recurse)
foreach($item in $dir){
    Rename-Item -LiteralPath $item.FullName -NewName ($item.Name -replace "[\[\]]",'')
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Renamed '<$item>' to exclude brackets")
}


#script that uploads entire folders and its sub-files
$FromDir_SubDir = @(Get-ChildItem "C:\Users\vm305\Desktop\moviesToUpload\" -Directory)
$ftp = "ftp://Movies::###########@@192.168.1.179/"

Try{
    foreach ($folder in $FromDir_SubDir){
        $ftp2 = $ftp + "/$folder"
        $files = @(Get-ChildItem $folder.FullName -Recurse -File)
    
        $makeDir = [System.Net.WebRequest]::Create($ftp2)
        #$makeDir.Credentials = New-Object System.Net.NetworkCredential($user,$pass)
        $makeDir.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory
        $makeDir.GetResponse()
        LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Created Folder <$folder>")

        foreach($file in $files){
            $webclient = New-Object -TypeName System.Net.WebClient
            $uri = New-Object -TypeName System.Uri -ArgumentList "$ftp2/$($file.Name)"

            $webclient.UploadFile("$uri", $file.FullName)
            LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Uploaded file: '<$($file)>' to folder: '<$folder>'")
            Send-MailMessage -SmtpServer 'ESXI-Plex' -To @("varunmaster95@gmail.com","nvelani2@gmail.com") -From 'Plex@ESXI-Plex.com' -Subject 'New Movie Uploaded!' -Body "Following movie has been uploaded: $($file.Name)"

            Remove-Item $file.FullName -Recurse -Force 
        }
        cp $folder.FullName -Recurse  -Destination "T:\Movies" -Container
        LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Copied folder '<$($folder.FullName)>' to BACKUP drive")
        rmdir $folder.FullName -Force -Recurse
    }
}
Catch{
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": $_.Exception.Message")
}


#script that uploads only files and no subfolders
$FromDir = Get-ChildItem "C:\Users\vm305\Desktop\moviesToUpload\" -File
$ftp = "ftp://Movies:###########@192.168.1.179/"

Try{
    foreach ($file in $FromDir){
        $ftp1 = $ftp + "/$($file.Name)"

        $webclient = New-Object -TypeName System.Net.WebClient
        $uri = New-Object -TypeName System.Uri -ArgumentList $ftp1

        LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Uploaded file <$($file)>")
        $webclient.UploadFile($uri, $file.FullName)

        cp $file.fullname "T:\Movies"
        LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Copied file '<$($file.FullName)>' to BACKUP drive")
        Send-MailMessage -SmtpServer 'ESXI-Plex' -To @("varunmaster95@gmail.com","nvelani2@gmail.com") -From 'Plex@ESXI-Plex.com' -Subject 'New Movie Uploaded!' -Body "Following movie has been uploaded: $($file.Name)"
        
        Remove-Item $file.FullName
    }
}
Catch{
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": $_.Exception.Message")
}

LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Script ended")
LogWrite("------------------------------------End------------------------------------")
