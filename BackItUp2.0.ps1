# TODO:
# Copy the same logic from movie for C:\Scripts and T:\Files\KeePass and T:\Files\ISOs
# Add the flags to skip each of the parts

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)] [switch] $skipMovies = $false,
    [Parameter(Mandatory = $false)] [switch] $skipScripts = $false,
    [Parameter(Mandatory = $false)] [switch] $skipISOs = $false
)

$stopwatch = [system.diagnostics.stopwatch]::StartNew()
$LogFile = (Join-Path "C:\Logs\" -ChildPath "$($MyInvocation.MyCommand.Name).log")

function LogWrite($logString, $color = "White") {
    Add-content $Logfile -value ((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": $logString ")
    if ($color) {
        Write-Host $logString -ForegroundColor $color
    }
}

function createObjOfNameAndLastWriteTime($currBackedUpFiles, $baseDirToSearch) {
    $obj = @{}
    foreach ($movie in $currBackedUpFiles) {
        $obj.Add($movie, @(Get-Item -Path "$($baseDirToSearch)$($movie)").LastWriteTime.ToString('yyyy/MM/dd'))
    }
    return $obj
    # | Out-Null #we use Out-Null bc by default when we return values or objects, it prints it to screen 
}

function BackUpMovies() {
    if ($skipMovies -eq $false) { #need to check if the switch param is false bc then that means we want to back up movies
        $offSiteBackUpsAllMovies = @((Get-ChildItem -Path 'E:\Movies' -Directory).Name)
        $offSiteBackUpsAllMoviesObj = createObjOfNameAndLastWriteTime($offSiteBackUpsAllMovies, "E:\Movies\")

        $AllMoviesToBackup = @(((Get-ChildItem -Path 'T:\Movies' -Directory).Name))
        Try {
            foreach ($movie in $AllMoviesToBackup) {
                $currMovieToBackupLastWriteTime = @(Get-Item -Path "T:\Movies\$($movie)").LastWriteTime.ToString('yyyy/MM/dd')
                if (($movie -notin $offSiteBackUpsAllMovies) -and ($currMovieToBackupLastWriteTime -ne $offSiteBackUpsAllMoviesObj[$($movie)])) {
                    Copy-Item -Path "T:\Movies\$($movie)" -Destination "E:\Movies\" -Recurse -Force
                    LogWrite("Copied Movie <$($movie)> to E:\Movies", "Green")
                }
                else {
                    LogWrite("Movie <$($movie)> already backed up and/or the LastWriteTime are equal", "Yellow")
                }
            }
        }
        Catch {
            LogWrite("ERROR OCCURRED: $_.Exception.Message", "Red")
        }
    }
    else {
        LogWrite("Skipping Movies because flag was true for skipMovies: $($skipMovies)", "Yellow")
    }
}

function BackUpScripts() {
    if ($skipScripts -eq $false) {
        #logic 
    } else {
        LogWrite("Skipping Movies because flag was true for skipScripts: $($skipScripts)", "Yellow")
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
