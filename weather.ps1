$zip = Read-Host -Prompt 'Enter the zip you want'
$content = (Invoke-WebRequest -uri https://weather.com/weather/today/l/$zip).content

if([System.IO.File]::Exists("C:\Users\vmaster\Desktop\weather.html")){
    Write-Host " "
    Write-Host " "
    Write-Host "File already exists. Also check out Test-Path `$path -PathType Leaf"
    }
else{
    New-Item -Path "C:\Users\vmaster\Desktop" -Name weather.html
}

$writeToFile = Out-File -FilePath "C:\Users\vmaster\Desktop\weather.html" -InputObject $content -Encoding string

C:\Users\vmaster\Desktop\weather.html