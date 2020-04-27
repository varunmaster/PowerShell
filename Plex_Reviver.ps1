$Logfile = "C:\Logs\$($MyInvocation.MyCommand.Name).log"
function LogWrite($logString)
{
   Add-content $Logfile -value $logString 
}
if(Get-Process "Plex Media Server" -ErrorAction SilentlyContinue ){
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Plex already running...exiting")
    Exit 0
    }
else {
    LogWrite((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": Plex not running...starting now")
    Start-Process "C:\Program Files (x86)\Plex\Plex Media Server\Plex Media Server.exe"
    Send-MailMessage -SmtpServer "###" -From "###" -To @("###") -Subject "Plex restarted" -BodyAsHtml "Plex just restarted. $(Get-Date -Format G)"
}
