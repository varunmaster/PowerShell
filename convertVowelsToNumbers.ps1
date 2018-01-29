$vowels =  @('a','e','i','o','u') #'aeiou' 
$name = Read-Host -Prompt 'Enter a name'

$name = $name.ToCharArray()

for($i = 0; $i -lt $name.Length; $i++) {
    for($j = 0; $j -lt $vowels.Length; $j++){
        if($name[$i] -eq $vowels[$J]){
            $name = $name -replace $name[$i], ($vowels.IndexOf($vowels[$j]) + 1)
        }
    }
}
$name -join ''

#doing above but with only one for loop
for($i = 0; $i -lt $name.Length; $i++){
    if($vowels -contains $name[$i]){
        $name = $name -replace $name[$i], ($vowels.IndexOf($vowels[$i]) + 1)
    }
}
$name -join ''