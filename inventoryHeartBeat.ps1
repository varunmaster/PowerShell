$Logfile = "C:\Logs\$($MyInvocation.MyCommand.Name).log"
function LogWrite($logString) {
    Add-content $Logfile -value "$($(Get-Date).toString('yyyy/MM/dd HH:mm:ss')): $logString"
}

$ping4001 = Test-NetConnection 127.0.0.1 -Port 4001
$ping4000 = Test-NetConnection 127.0.0.1 -Port 4000

if ($ping4001.TcpTestSucceeded -eq $false) {
    #code to start the front end of the inventory site
    LogWrite("Starting front end...current status:`n`t4001:$($ping4001.TcpTestSucceeded)")
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -verb runas -WorkingDirectory "C:\Users\Administrator\NewSite4000React\new-site-4000\client" -ArgumentList {/k npm start}
    Send-MailMessage -To "v@gmail.com" -From "e@gmail.com" -Subject "Inventory site restarted" -SmtpServer "" -Body "<p>Front-end of inventory site restarted</p><ul><li>Old status: $($ping4001.TcpTestSucceeded)</li></ul>" -BodyAsHtml
}

if ($ping4000.TcpTestSucceeded -eq $false) {
    LogWrite("Starting back end...current status:`n`t4000:$($ping4000.TcpTestSucceeded)")
    Start-Process -FilePath "C:\Windows\System32\cmd.exe" -verb runas -WorkingDirectory "C:\Users\Administrator\NewSite4000React\new-site-4000\" -ArgumentList {/k npm run dev}
    Send-MailMessage -To "v@gmail.com" -From "e@gmail.com" -Subject "Inventory site restarted" -SmtpServer "" -Body "<p>Back-end of inventory site restarted</p><ul><li>Old status: $($ping4000.TcpTestSucceeded)</li></ul>" -BodyAsHtml
}

if (($ping4001.TcpTestSucceeded -or $ping4000.TcpTestSucceeded) -eq $true) {
    LogWrite("Ping returned site is alive:`n`t4000:$($ping4000.TcpTestSucceeded)`n`t4001:$($ping4000.TcpTestSucceeded)`n exiting now")
    exit 0
}
