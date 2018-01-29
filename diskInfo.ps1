cd "C:\Users\vmaster\Desktop"
$date = Get-Date

if([System.IO.File]::Exists("C:\Users\vmaster\Desktop\DiskStatus1.txt")){
    Write-Host " "
    Write-Host " "
    Write-Host "File already exists. Also check out Test-Path `$path -PathType Leaf"
    }
else{
    New-Item -Path "C:\Users\vmaster\Desktop" -Name DiskStatus1.txt -ItemType file -Value "Here is the disk(s) info:" 
}

$diskInfo = Get-Disk
$diskInfoToFile = Out-File -FilePath "C:\Users\vmaster\Desktop\DiskStatus1.txt" -InputObject $date -Append -Encoding utf8 -NoClobber
$diskInfoToFile = Out-File -FilePath "C:\Users\vmaster\Desktop\DiskStatus1.txt" -InputObject $diskInfo -Append -Encoding utf8 -NoClobber
