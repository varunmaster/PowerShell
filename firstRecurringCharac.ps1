$inputString = Read-Host -Prompt 'Enter input string'
$inputStringList = New-Object System.Collections.Generic.List[System.Object]

for($i = 0; $i -lt $inputString.Length; $i++){
    if($inputString[$i] -notin $inputStringList){
        $inputStringList.Add($inputString[$i])
    }else{
        Write-Host "First duplicate at position:" $i
        Write-Host "First duplicate character:" $inputString[$i]
        break
    }
}

Read-Host -Prompt 'press enter key to exit'