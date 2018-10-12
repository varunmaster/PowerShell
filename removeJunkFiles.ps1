$date = Get-Date
try{
Get-ChildItemasd -Path C:\Users\Varun\Desktop\incomingMovies | Where-Object {($_ -like '*.txt') -or ($_ -like '*.url') -or ($_ -like '*.nfo') -or  ($_ -like '*.ass')} | Remove-Item
}catch{
Out-File -FilePath "C:\Users\Varun\Desktop\removeJunkFiles_log.txt" -InputObject $date -Append -Encoding utf8 -NoClobber
Out-File -FilePath "C:\Users\Varun\Desktop\removeJunkFiles_log.txt" -InputObject $_.Exception -Append -Encoding utf8 -NoClobber 
}

C:\Users\Varun\Desktop\Scripts\moveFilesToSubtitlesFolder.ps1