(Get-ChildItem "T:\Movies" -Directory -Recurse | ? {$_.Name -notin ("sub", "Other", "Subs", "Subtitles", "Subtitle")}) | Out-File "T:\MovieInventory.txt" 
(Get-ChildItem "T:\Shows" -Directory -Recurse) | Out-File "T:\ShowInventory.txt" 
(Get-ChildItem "T:\Files" -Directory -Recurse) | Out-File "T:\FileInventory.txt" 