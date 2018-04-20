$subreddit = Read-Host -Prompt 'Enter the subreddit you want'
$content = Invoke-WebRequest -uri https://www.reddit.com/r/$subreddit -UserAgent ([Microsoft.PowerShell.Commands.PSUserAgent]::Chrome)

$links = ($content.Links | Where-Object {$_ -Like 'https*'}).href


#if([System.IO.File]::Exists("C:\Users\vmaster\Desktop\totallyInconspicousFile.html")){
#    Write-Host " "
#    Write-Host " "
#    Write-Host "File already exists. Also check out Test-Path `$path -PathType Leaf"
#    }
#else{
#    New-Item -Path "C:\Users\vmaster\Desktop" -Name totallyInconspicousFile.html
#}

#$writeToFile = Out-File -FilePath "C:\Users\vmaster\Desktop\totallyInconspicousFile.html" -InputObject $content.links.href -Encoding string