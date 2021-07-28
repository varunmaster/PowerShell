# TODO:
# have fun
# 
[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)] [switch] $skipMovies = $false,
    [Parameter(Mandatory = $false)] [switch] $skipScripts = $false,
    [Parameter(Mandatory = $false)] [switch] $skipMiscFiles = $false
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

function BackUpMovies {
    if ($skipMovies -eq $false) { #need to check if the switch param is false bc then that means we want to back up movies
        $prodE = "E:\Movies"
        $prodT = "T:\Movies"
        $testE = "C:\DevStuff\Data\E"
        $testT = "C:\DevStuff\Data\T"
        $offSiteBackUpsAllMovies = @((Get-ChildItem -Path $prodE -Directory).Name)
        $offSiteBackUpsAllMoviesObj = createObjOfNameAndLastWriteTime $offSiteBackUpsAllMovies $prodE

        $AllMoviesToBackup = @(((Get-ChildItem -Path "$($prodT)" -Directory).Name))
        Try {
            foreach ($movie in $AllMoviesToBackup) {
                $currMovieToBackupLastWriteTime = @(Get-Item -Path "$($prodT)\$($movie)").LastWriteTime.ToString('yyyy/MM/dd')
                if (($movie -notin $offSiteBackUpsAllMovies) -and ($currMovieToBackupLastWriteTime -ne $offSiteBackUpsAllMoviesObj[$($movie)])) {
                    LogWrite "Copying Movie <$($movie)> to $($prodE)" "Green"
                    Copy-Item -Path "$($prodT)\$($movie)" -Destination "$($prodE)\" -Recurse -Force
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

function BackUpScripts {
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

function BackUpMiscFiles {
    if ($skipMiscFiles -eq $false) {
        $offSiteBackUpsAllISOs = @((Get-ChildItem -Path 'E:\Files\ISOs').Name)
        #$offSiteBackUpsAllISOs = @((Get-ChildItem -Path 'C:\DevStuff\Data\E').Name) 
        $offSiteBackUpsAllISOsObj = createObjOfNameAndLastWriteTime $offSiteBackUpsAllISOs "E:\Files\ISOs" 
        #$offSiteBackUpsAllISOsObj = createObjOfNameAndLastWriteTime $offSiteBackUpsAllISOs "C:\DevStuff\Data\E"
        
        $AllISOsToBackup = @(((Get-ChildItem -Path "T:\Files\ISOs").Name))
        Try {
            foreach ($ISO in $AllISOsToBackup) {
                $currISOToBackupLastWriteTime = @(Get-Item -Path "T:\Files\ISOs\$($ISO)").LastWriteTime.ToString('yyyy/MM/dd')
                if (($ISO -notin $offSiteBackUpsAllISOs) -and ($currISOToBackupLastWriteTime -ne $offSiteBackUpsAllISOsObj[$($ISO)])) {
                    LogWrite "Copying ISO <$($ISO)> to E:\Files\ISOs" "Green"
                    Copy-Item -Path "T:\Files\ISOs\$($ISO)" -Destination "E:\Files\ISOs" -Recurse -Force -Container
                    #Copy-Item -Path "T:\Files\ISOs\$($ISO)" -Destination "C:\DevStuff\Data\E" -Recurse -Force -Container
                } else {
                    LogWrite "Script <$($ISO)> already backed up and/or the LastWriteTime are equal" "Yellow"
                }
            }
            LogWrite "Copying KeePass files now" "Green"
            Copy-Item -Path "T:\Files\KeePass" -Destination "E:\Files\KeePass" -Recurse -Force -Container
            #Copy-Item -Path "T:\Files\KeePass" -Destination "C:\DevStuff\Data\E" -Recurse -Force -Container
        }
        Catch {
            LogWrite "ERROR OCCURRED: $_.Exception.Message" "Red"
        }
    } else {
        LogWrite "Skipping Misc files because flag was true for skipMiscFiles: $($skipMiscFiles)" "Yellow"
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
LogWrite "<-----------Going to start backing up Scripts----------->" "Cyan"
BackUpScripts
LogWrite "<-----------Going to start backing up Misc files----------->" "Cyan"
BackUpMiscFiles

#LogWrite "<-----------Completed backing up....ejecting device----------->" "Red"
#$device = Get-WmiObject -Class Win32_Volume | Where {$_.Name -eq "E:\"}
#$device.Dismount($false,$false)

LogWrite "`
#######################################################################`
#######################           End           #######################`
#######################################################################`
" "Magenta"
$stopwatch.Stop()
LogWrite "Total time: <$($stopwatch.Elapsed.TotalSeconds)>" "Magenta"
