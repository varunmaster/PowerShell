$dirsToScan = @()
$filesToMove = @()

#scan each dir and add the file to the filesToMove array
foreach($dir in $dirsToScan){
    foreach($file in (Get-ChildItem $dir -Recurse -Force)){
        $filesToMove += $file
    }
}

foreach($file in $filesToMove){
    #if $file in list of backed up files and size is diff or lastwritetime is diff then backup
}

#hash function
function getFileHash($fileName){
    $index = -1
    $nameToCharArr = ([char]$fileName).ToCharArray()
    $sum = 0
    for ($i = 0; $i -lt $nameToCharArr.length; $i++){
        $sum += $nameToCharArr[$i]
    }
    $index = $sum % 2 #change the mod
}



<#
TODO:
    - Change the directory for $custodialFiles to the directory in LEND
    - Change the directory for Destination param in the Copy-Item
#>

#Import-Module (Join-Path $PSScriptRoot LogWriter)
#initialize-log -counters 'FilesMoved'

#$custodialFiles = @((Get-ChildItem C:\Users\vmaster\Desktop\Test -Recurse).FullName)
#$custodialFilesTemp += $custodialFiles | ? {$_ -like '*Loan*'}
#$filesToMove = @()

try{
    foreach($file in $custodialFilesTemp){
        if((Get-Item $file).LastWriteTime.ToString('MM/dd/yyyy') -eq ("11/28/2018")){
            $filesToMove += $file
 #           write-log "File to move: $file" -level Info
        }else{continue}
    }
}
catch{
#    write-log "$_.Exception" -level Error
}

try{
    foreach($file in $filesToMove){
        Copy-Item -Path $file -Destination "C:\Users\vmaster\Desktop\Test\Test2"
#        write-log "Moved file: $file" -level Info
    }
}
catch{
#    write-log "$_.Exception" -level Error
}
