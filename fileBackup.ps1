$dirsToScan = @()
$filesToBackup = @()
$backupDir = @()
$filesInBackup = @{}
#Hash_Array.Add("Key", "Value")
#Hash_Array.Key = "value" #edits item and if doesnt exist, then adds it
#Hash_Array.Remove("Key")
#Hash_Array."key" #finds the key/value pair
#Hash_Array.ContainsKey("key")
#Hash_Array.ContainsValue("Value") #used like: "*value*"



#hash function to scan the backup and add them to the hashtable
function getFileHash($fileName){
    $index = -1
    $nameToCharArr = [int[]][char[]]$fileName
    $sum = 0
    for ($i = 0; $i -lt $nameToCharArr.length-1; $i++){
        $sum += $nameToCharArr[$i]
    }
    $index = $sum % 350 #change the mod
    return $index
}



#scan the backup directory and add the filenames to the hashtables
foreach($file in $backupDir){
    $filesInBackup.Add((getFileHash -fileName $file.FullName),"$file.FullName")
}



#scan each dir and add the file to the filesToMove array
foreach($dir in $dirsToScan){
    foreach($file in (Get-ChildItem $dir -Recurse -Force).FullName){
        $filesToMove += $file
    }
}




foreach($file in $filesToMove){
    #if file in filesInBackup and (size is diff or lastwritetime is diff then backup it up)
    #else back it up
    if (){
    }
    else{
    }
}






<#
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
#>