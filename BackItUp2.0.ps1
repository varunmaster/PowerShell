# TODO:
# Copy the same logic from movie for C:\Scripts and T:\Files\KeePass and T:\Files\ISOs
#

$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$LogFile = (Join-Path "C:\Logs\" -ChildPath "$($MyInvocation.MyCommand.Name).log")
$offSiteBackUpsAllMoviesObj = @{}
$offSiteBackUpsAllMovies = @((Get-ChildItem -Path 'E:\Movies' -Directory).Name)

function LogWrite($logString, $color = "White") {
   Add-content $Logfile -value ((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": $logString ")
   if ($color) {
       Write-Host $logString -ForegroundColor $color
   }
}

function createObjOfNameAndLastWriteTime() {
    foreach ($movie in $offSiteBackUpsAllMovies) {
        $offSiteBackUpsAllMoviesObj.Add($movie, @(Get-Item -Path "E:\Movies\$($movie)").LastWriteTime.ToString('yyyy/MM/dd'))
    }
    return $offSiteBackUpsAllMoviesObj | Out-Null #we use Out-Null bc by default when we return values or objects, it prints it to screen 
}

function BackUpMovies() {
    #call function to create the object
    createObjOfNameAndLastWriteTime

    $AllMoviesToBackup = @(((Get-ChildItem -Path 'T:\Movies' -Directory).Name))
    Try {
        foreach($movie in $AllMoviesToBackup) {
            $currMovieToBackupLastWriteTime = @(Get-Item -Path "T:\Movies\$($movie)").LastWriteTime.ToString('yyyy/MM/dd')
            if (($movie -notin $offSiteBackUpsAllMovies) -and ($currMovieToBackupLastWriteTime -ne $offSiteBackUpsAllMoviesObj[$($movie)])) {
                Copy-Item -Path "T:\Movies\$($movie)" -Destination "E:\Movies\" -Recurse -Force
                LogWrite("Copied Movie <$($movie)> to E:\Movies", "Green")
            } else {
                LogWrite("Movie <$($movie)> already backed up and/or the LastWriteTime are equal", "Yellow")
            }
        }
    } Catch {
        LogWrite("ERROR OCCURRED: $_.Exception.Message", "Red")
    }
}

LogWrite("`
#######################################################################`
######################           Start           ######################`
#######################################################################`
", "Red")

LogWrite("<-----------Running Inventory----------->", "Cyan")
#C:\Scripts\inventory.ps1
LogWrite("<-----------Going to start backing up Movies----------->", "Cyan")
BackUpMovies

LogWrite("`
#######################################################################`
#######################           End           #######################`
#######################################################################`
", "Red")
$stopwatch.Stop()
LogWrite("Total time: <$($stopwatch.Elapsed.TotalSeconds)>", , "Cyan")
