if(Get-Process -Name 'Plex Media Server'){
    exit
}else{
    Start-Process "C:\Program Files (x86)\Plex\Plex Media Server\Plex Media Server.exe"
}