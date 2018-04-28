#Directory where files are located
$FromDir= Get-ChildItem "C:\Users\vm305\Desktop\moviesToUpload" -Recurse
$FromDir1= Get-ChildItem "C:\Users\vm305\Desktop\moviesToUpload" -Recurse

#ftp server info
$ftp = "ftp://Varun@192.168.1.179/"
$user = "Varun"
$pass = "Drqjrk2hnhbg9ngt"

$webclient = New-Object System.Net.WebClient
$webclient.Credentials = New-Object System.Net.NetworkCredential($user,$pass)


#Pick up files
foreach($item in $FromDir){
    "Uploading $item..."
    $uri = New-Object System.Uri($ftp+$item.Name)
    $webclient.UploadFile($uri, $item.FullName)
}

#foreach($item in $FromDir){
#    Remove-Item -Path $item.FullName -Recurse
#}


$FromDir1| Remove-Item -Recurse

<#
#Download files - Below code works but I need to use a wildcard in the file name as it changes and I can't figure out how to do that.

$target = "pc name\C$\FTP\Download\Notes.txt"
$source =  "<ftp address>/Sample_file.txt"

$WebClient.DownloadFile($source, $target)
#>