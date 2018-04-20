$food = @('Ramen','sky thai', 'rumi', 'enfes', 'honshu', 'teppan', 'kravery', 'mall', 'kripy pizza','5 guys','cava','food trucks')

Write-Host $($food | Get-Random )

Read-Host -Prompt 'Press enter key to close this box'