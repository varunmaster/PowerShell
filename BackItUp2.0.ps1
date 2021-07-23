# TODO:
# Copy the same logic from movie for T:\Files\KeePass and T:\Files\ISOs
# Add the flags to skip each of the parts
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)] [switch] $skipMovies = $false,
    [Parameter(Mandatory = $false)] [switch] $skipScripts = $false,
    [Parameter(Mandatory = $false)] [switch] $skipISOs = $false
)

$stopwatch = [system.diagnostics.stopwatch]::StartNew()
$LogFile = (Join-Path "C:\Logs\" -ChildPath "$($MyInvocation.MyCommand.Name).log")

function LogWrite {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$logString,

        [Parameter(Mandatory)]
        [string]$color
    )
    Add-content $Logfile -value ((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": $logString")
    Write-Host $logString -ForegroundColor $color
}

function createObjOfNameAndLastWriteTime {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$currBackedUpFiles,

        [Parameter(Mandatory)]
        [string]$baseDirToSearch
    )
    $obj = @{}
    foreach ($file in $currBackedUpFiles) {
        $LWT = @(Get-Item -Path "$baseDirToSearch\$file").LastWriteTime.ToString('yyyy/MM/dd')
        $obj.Add($file, $LWT)
    }
    return $obj
    # | Out-Null #we use Out-Null bc by default when we return values or objects, it prints it to screen 
}

function BackUpMovies() {
    if ($skipMovies -eq $false) { #need to check if the switch param is false bc then that means we want to back up movies
        $prodE = "E:\Movies"
        $prodT = "T:\Movies"
        $testE = "C:\DevStuff\Data\E"
        $testT = "C:\DevStuff\Data\T"
        $offSiteBackUpsAllMovies = @((Get-ChildItem -Path $testE -Directory).Name)
        $offSiteBackUpsAllMoviesObj = createObjOfNameAndLastWriteTime $offSiteBackUpsAllMovies $testE

        $AllMoviesToBackup = @(((Get-ChildItem -Path "$($testT)" -Directory).Name))
        Try {
            foreach ($movie in $AllMoviesToBackup) {
                $currMovieToBackupLastWriteTime = @(Get-Item -Path "$($testT)\$($movie)").LastWriteTime.ToString('yyyy/MM/dd')
                if (($movie -notin $offSiteBackUpsAllMovies) -and ($currMovieToBackupLastWriteTime -ne $offSiteBackUpsAllMoviesObj[$($movie)])) {
                    LogWrite "Copying Movie <$($movie)> to $($testE)" "Green"
                    Copy-Item -Path "$($testT)\$($movie)" -Destination "$($testE)\" -Recurse -Force
                } else {
                    LogWrite "Movie <$($movie)> already backed up and/or the LastWriteTime are equal" "Yellow"
                }
            }
        }
        Catch {
            LogWrite "ERROR OCCURRED: $_.Exception.Message" "Red"
        }
    } else {
        LogWrite "Skipping Movies because flag was true for skipMovies: $($skipMovies)" "Yellow"
    }
}

function BackUpScripts() {
    if ($skipScripts -eq $false) {
        $offSiteBackUpsAllScripts = @((Get-ChildItem -Path 'E:\Scripts').Name)
        #$offSiteBackUpsAllScripts = @((Get-ChildItem -Path 'C:\DevStuff\Data\E').Name) 
        $offSiteBackUpsAllScriptsObj = createObjOfNameAndLastWriteTime $offSiteBackUpsAllScripts "E:\Scripts" 
        #$offSiteBackUpsAllScriptsObj = createObjOfNameAndLastWriteTime $offSiteBackUpsAllScripts "C:\DevStuff\Data\E"

        $AllScriptsToBackup = @(((Get-ChildItem -Path "C:\Scripts").Name))
        Try {
            foreach ($script in $AllScriptsToBackup) {
                $currScriptToBackupLastWriteTime = @(Get-Item -Path "C:\Scripts\$($script)").LastWriteTime.ToString('yyyy/MM/dd')
                if (($script -notin $offSiteBackUpsAllScripts) -and ($currScriptToBackupLastWriteTime -ne $offSiteBackUpsAllScriptsObj[$($script)])) {
                    LogWrite "Copying Script <$($script)> to E:\Scripts\" "Green"
                    Copy-Item -Path "C:\Scripts\$($script)" -Destination "E:\Scripts\" -Recurse -Force
                    #Copy-Item -Path "C:\Scripts\$($script)" -Destination "C:\DevStuff\Data\E" -Recurse -Force 
                } else {
                    LogWrite "Script <$($script)> already backed up and/or the LastWriteTime are equal" "Yellow"
                }
            }
        }
        Catch {
            LogWrite "ERROR OCCURRED: $_.Exception.Message" "Red"
        }
    } else {
        LogWrite "Skipping scripts because flag was true for skipScripts: $($skipScripts)" "Yellow"
    }
}

LogWrite "`
#######################################################################`
######################           Start           ######################`
#######################################################################`
" "Magenta"

LogWrite "<-----------Running Inventory----------->" "Cyan"
#C:\Scripts\inventory.ps1
LogWrite "<-----------Going to start backing up Movies----------->" "Cyan"
BackUpMovies
LogWrite "<-----------Going to start backing up Script----------->" "Cyan"
BackUpScripts

LogWrite "`
#######################################################################`
#######################           End           #######################`
#######################################################################`
" "Magenta"
$stopwatch.Stop()
LogWrite "Total time: <$($stopwatch.Elapsed.TotalSeconds)>" "Magenta"
