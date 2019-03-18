$Logfile = "C:\Users\vm305\Desktop\Logs\$($MyInvocation.MyCommand.Name).log"
function LogWrite($logString)
{
   Add-content $Logfile -value $logString
}

LogWrite("-----------------------------------Start-----------------------------------")
LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Script started")


$FromDir_SubDir = Get-ChildItem "C:\Users\vm305\Desktop\moviesToUpload" -Directory
$ftp = "ftp://Movies:###########@192.168.1.179/"

Try{
    foreach ($folder in $FromDir_SubDir){
        $ftp2 = $ftp + "/$folder"
        $files = @(Get-ChildItem $folder.FullName -Recurse)
    
        $makeDir = [System.Net.WebRequest]::Create($ftp2)
        #$makeDir.Credentials = New-Object System.Net.NetworkCredential($user,$pass)
        $makeDir.Method = [System.Net.WebRequestMethods+FTP]::MakeDirectory
        $makeDir.GetResponse()
        LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Created Folder <$folder>")

        foreach($file in $files){
            $webclient = New-Object -TypeName System.Net.WebClient
            $uri = New-Object -TypeName System.Uri -ArgumentList "$ftp2/$($file.Name)"

            LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Uploaded file: '<$($file)>' to folder: '<$folder>'")
            $webclient.UploadFile("$uri", $file.FullName)

            #Remove-Item $file.FullName -Recurse -Force 
        }
        #cp $folder "T:\Movies" -Recurse
        #rmdir $folder.FullName
    }
}
Catch{
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": $_.Exception.Message")
}



$FromDir = Get-ChildItem "C:\Users\vm305\Desktop\moviesToUpload\" -File
$ftp = "ftp://Movies:###########@192.168.1.179/"

Try{
    foreach ($file in $FromDir){
        $ftp1 = $ftp + "/$($file.Name)"

        $webclient = New-Object -TypeName System.Net.WebClient
        $uri = New-Object -TypeName System.Uri -ArgumentList $ftp1

        LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Uploaded file <$($file)>")
        $webclient.UploadFile($uri, $file.FullName)

        #cp $file.fullname "T:\Movies"

        #Remove-Item $file.FullName
    }
}
Catch{
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": $_.Exception.Message")
}

LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Script ended")
LogWrite("------------------------------------End------------------------------------")
