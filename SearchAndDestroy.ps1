Write-Host "Here are the files that will be destroyed:" -ForegroundColor Yellow
$movieList = @(Get-ChildItem -Path $drive -Filter *$($name)* -Directory)
$movieList.ForEach({Write-Host $_.FullName "-------" $_.LastWriteTime -ForegroundColor Red})
Write-Host "Do you want to run in bulk mode or individual mode (type exit to exit)? B/I" -ForegroundColor Yellow
$bulk = Read-Host

if ($bulk.ToLower() -eq 'b') {
    Write-Host "Confirm again if this list should be deleted (Y/N):" -ForegroundColor Yellow
    $movieList.ForEach({Write-Host $_.FullName "-------" $_.LastWriteTime -ForegroundColor Red})
    $del = Read-Host
    if ($del.ToLower() -eq 'y') {
        $movieList.ForEach({Remove-Item -Path $_.FullName -Recurse -Force})
        Write-Host "Deleted all folders" -ForegroundColor Magenta
    } 
    else {
        exit 0
    }
} elseif ($bulk.ToLower() -eq 'i') {
    foreach ($movie in $movieList) {
        Write-Host $movie.FullName "-------" $movie.LastWriteTime -ForegroundColor Red
        Write-Host "Delete this folder? (Y/N)" -ForegroundColor Yellow
        $confirm = Read-Host
        if ($confirm.ToLower() -eq 'y') {
            $folder = Get-Item $movie.FullName
            Remove-Item -Path $folder -Recurse -Force
            Write-Host "Deleted folder...moving on" -ForegroundColor Magenta
        } else {
            Write-Host "Skipping...moving on" -ForegroundColor DarkMagenta
            continue
        }
    }
} elseif ($bulk.ToLower() -eq "exit") {
    exit 0
}
else {
    exit 0
}
