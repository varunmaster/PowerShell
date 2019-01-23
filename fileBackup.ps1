param(
    [string]$dirsToScan = "C:\Users\vmaster\Desktop\Test", #default value when param not specified
    [string]$backupDir = "C:\Users\vmaster\Desktop\Test2"  #default value when param not specified
)


#$dirsToScan = "C:\Users\vmaster\Desktop\Test"
#$backupDir = "C:\Users\vmaster\Desktop\Test2"
$filesToBackup = @()
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
#Key-Value will be getFileHash and file.name
foreach($file in (Get-ChildItem $backupDir -Recurse)){
    $filesInBackup.Add((getFileHash -fileName $file.Name),$file)
}


#check the dir to see if there are any files not in subdirectories
if((Get-ChildItem $dirsToScan -File).Count -gt 0){
    foreach($file in (Get-ChildItem $dirsToScan -File)){
        $filesToBackup += (Join-Path -Path $dirsToScan -ChildPath $file)
    }
}


#scan each dir and add the file to the filesToMove array with the fullNmae
foreach($dir in ((Get-ChildItem $dirsToScan -Directory).FullName)) {
    foreach($file in (Get-ChildItem $dir -File -Recurse)){
        $filesToBackup += (Join-Path -Path $dir -ChildPath $file)
    }
}


#if file in filesInBackup and (size is diff or lastwritetime is diff then backup it up)
#else if, file doesnt exist in backup, backup it up
#else skip
foreach($file in $filesToBackup){
    #splitting it so we can compare just the file names and not the directory since they will be different
    if ($filesInBackup.ContainsValue($file.Split("\")[-1]) -and `
        (($file.Length -ne (Get-Item $filesInBackup.ContainsValue($file.Split("\")[-1])).Length) -or ($file.LastWriteTime -ne (Get-Item $filesInBackup.ContainsValue($file.Split("\")[-1])).LastWriteTime))){
        Copy-Item $file -Destination $backupDir
    }
    elseif($file.Split("\")[-1] -notin $filesInBackup.ContainsValue($file.Split("\")[-1])){
        Copy-Item $file -Destination $backupDir
    }
    else{
        continue
    }
}
