[CmdletBinding()]
Param (
    [Parameter(Mandatory=$false)] $drive = 'T:\Movies',
    [Parameter(Mandatory=$true)] $name
)


Write-Host "Here are the files that will be destroyed:" -ForegroundColor Yellow
$movieList = @(Get-ChildItem -Path $drive -Filter *$($name)* -Directory)
$movieList.ForEach({Write-Host $_.FullName -ForegroundColor Red})
Write-Host "Do you want to run in bulk mode or individual mode? B/I" -ForegroundColor Yellow
$bulk = Read-Host

if ($bulk.ToLower() -eq 'b') {
    Write-Host "Confirm again if this list should be deleted (Y/N):" -ForegroundColor Yellow
    $movieList.ForEach({Write-Host $_.FullName -ForegroundColor Red})
    $del = Read-Host
    if ($del.ToLower() -eq 'y') {
        $movieList.ForEach({Remove-Item -Path $_.FullName -Recurse -Force})
    } 
    else {
        exit 0
    }
} elseif ($bulk.ToLower() -eq 'i') {
    foreach ($movie in $movieList) {
        Write-Host $movie.FullName -ForegroundColor Red
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
} 
else {
    exit 0
}
