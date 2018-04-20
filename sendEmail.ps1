C:\Users\vmaster\Desktop\diskInfo.ps1

$email = 'vmaster@streetsolutions.com'
$SMTPServer = 'srvnj36b'
$SMTPPort = '25'
#$Password = 'vsmaster95'
$subject = 'Disk Status'
$data = (Get-Content -path C:\Users\vmaster\Desktop\DiskStatus1.txt | Out-String)
$smtp = New-Object System.Net.Mail.SmtpClient($SMTPServer, $SMTPPort);
#$smtp.EnableSSL = $true
#$smtp.Credentials = New-Object System.Net.NetworkCredential($email, $Password);

try{
    $smtp.Send($email, $email, $subject, $data ) #Send(from, to, subject, body)
    Write-Host " "
    Write-Host " "
    Write-Host "Success"
}
catch{
    Write-Host " "
    Write-Host "Failed"
    Write-Host $_.Exception.Message
    Write-Host $_.ScriptStackTrace
}
#####################################################################################################################################################################################
#$From = "varunmaster95@gmail.com"
#$To = "varunmaster95@gmail.com"
##$Cc = "YourBoss@YourDomain.com"
#$Attachment = "C:\temp\Some random file.txt"
#$Subject = "Email Subject"
#$Body = "Insert body text here"
#$SMTPServer = "smtp.gmail.com"
#$SMTPPort = "587"
#Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject `
#-Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl `
#-Credential (Get-Credential) #-Attachments $Attachment