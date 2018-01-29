cd C:\Users\
$fileName = Read-Host -Prompt 'Enter file name'
$dir = Read-Host -Prompt 'Enter directory'


for($i=0; $i -lt (Get-ChildItem -Path $dir -Recurse).Length; $i++) {
    Write-Host "Get-ChildItem -Path $dir"
    if((Get-ChildItem -Path $dir -Recurse)[$i].FullName | Where-Object{$_ -like "*$fileName*"}){
        Write-Host 'FOUND'
        (Get-ChildItem -Path $dir -Recurse)[$i].FullName
        break
    }else{
        Write-Host 'Searching...'
    }
}

Read-Host -Prompt 'Press the Enter key to exit...'