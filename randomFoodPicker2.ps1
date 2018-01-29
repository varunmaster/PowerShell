$food1 = Read-Host -Prompt 'Enter the first place you would like to eat at'
$food2 = Read-Host -Prompt 'Enter the second place you would like to eat at'
$moreOptions = Read-Host -Prompt 'Do you want to pick from more options? (Y/N)'

if($moreOptions.ToUpper() -eq 'Y'){
    $foodx = Read-Host -Prompt 'Enter the next place you would like to eat at'
    $foodArray = @($food1, $food2, $foodx) | Get-Random 
    #return $foodArray
}
else{
    $foodArray = @($food1, $food2) | Get-Random
    #return $foodArray 
}

Write-Host $foodArray

Read-Host -Prompt 'Press enter key to close this box'

C:\Users\vmaster\Desktop\randomFoodPicker2.ps1