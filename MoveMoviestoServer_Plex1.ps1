#Directory where files are located
$FromDir = Get-ChildItem "C:\Users\vm305\Desktop\moviesToUpload" -Recurse
$toDir = Get-Item \\VARUNPLEX-PC\Users\Varun\Desktop\incomingMovies\*


#ftp server info
$ftp = "ftp://Varun@192.168.1.179/"
$user = "Varun"
$pass = ""

$webclient = New-Object System.Net.WebClient
$webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)


#Pick up files and push
foreach($item in $FromDir){
    if ($($item.Name) -in $($toDir.Name)){
        #Write-Host "Skipping $item because already on server"
        continue
    }else{
        #"Uploading $item..."
        $uri = New-Object System.Uri($ftp+$item.Name)
        $webclient.UploadFile($uri, $item.FullName)
    }
}


$FromDir | Remove-Item -Recurse
