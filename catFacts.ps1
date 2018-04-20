 [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $CatFact = Invoke-RestMethod -Uri 'https://catfact.ninja/fact' -Method Get | Select-Object -ExpandProperty fact | Out-File 'C:\Users\vmaster\Desktop\test.txt'

$to = 'varunmaster95@gmail.com'
#$from = 'vmaster@streetsolutions.com'
$SMTPServer = 'srvnj36b'
$SMTPPort = '25'
$subject = 'Report error'
$data = (Get-Content -path C:\Users\vmaster\Desktop\test.txt | Out-String)
$smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort)
$smtp.Send($to, $to, $subject, $data)