$moviesToBackup = @()
$scriptsToBackup = @()
$GitHubBackup = @()
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()
$LogFile = (Join-Path "C:\Logs\" -ChildPath "$($MyInvocation.MyCommand.Name).log")

function LogWrite($logString)
{
   Add-content $Logfile -value ((Get-Date).toString("yyyy/MM/dd HH:mm:ss") + ": $logString ")
   Write-Host $logString
}
LogWrite("<-----------------------------------Start----------------------------------->")

function backupMovies(){
    $moviesToBackup = (gci T:\Movies\ | ? {$_.LastWriteTime -gt (Get-Date).AddDays(-14)} ).FullName
    Try{
        foreach ($movie in $moviesToBackup){
            Copy-Item -Path $movie -Destination "E:\Movies\" -Force -Recurse
            LogWrite("Copied Movie <$($movie)> to E:\Movies\")
        }
    }
    Catch{
        LogWrite("ERROR OCCURRED: $_.Exception.Message")
    }
}

function backupScripts(){
    $scriptsToBackup = (gci C:\Users\vm305\Desktop\Scripts1 -Recurse).FullName 
    Try{
        foreach ($script in $scriptsToBackup){
            Copy-Item -Path $script -Destination "T:\Files\Scripts1\" -Force -Recurse
            LogWrite("Copied Script <$($script)> to T:\Files\Scripts1\")
            Copy-Item -Path $script -Destination "E:\Files\Scripts1\" -Force -Recurse
            LogWrite("Copied Script <$($script)> to E:\Files\Scripts1")
        }
    }
    Catch{
        LogWrite("ERROR OCCURRED: $_.Exception.Message")
    }
}

function backupGitHub(){
    $GitHubBackup = (gci C:\Users\vm305\Documents\GitHub -Directory -Recurse | ? {$_.LastWriteTime -gt (Get-Date).AddDays(-14)}).FullName
    Try{
        foreach($item in $GitHubBackup){
            Copy-Item $item -Destination "T:\Files\GitHub\" -Force -Recurse
            LogWrite("Copied Script <$($item)> to T:\Files\Github\")
            Copy-Item -Path $item -Destination "E:\Files\GitHub\" -Force -Recurse
            LogWrite("Copied Script <$($item)> to E:\Files\GitHub\")
        }
    }
    Catch{
        LogWrite("ERROR OCCURRED: $_.Exception.Message")
    }
}

function backupMiscFiles(){
    $iso = (gci D:\ISOs -Recurse -File).FullName
    $kee = (gci D:\KeePass -Recurse).FullName
    Try{
        foreach($item in $iso){
            Copy-Item $item -Destination "T:\Files\ISOs\" -Force -Recurse
            LogWrite("Copied Script <$($item)> to T:\Files\ISOs\")
        }
        foreach($item in $kee){
            Copy-Item $item -Destination "T:\Files\KeePass" -Force -Recurse
            LogWrite("Copied Script <$($item)> to T:\Files\KeePass")
        }
        
    }
    Catch{
        LogWrite("ERROR OCCURRED: $_.Exception.Message")
    }
}

LogWrite("Going to start backing up Movies")
backupMovies
LogWrite("Going to start backing up Scripts")
backupScripts
LogWrite("Going to start backing up GitHub")
backupGitHub
LogWrite("Going to start backing up Misc files")
backupMiscFiles

$stopwatch.Stop()
LogWrite("Total time: <$($stopwatch.Elapsed.TotalSeconds)>")
LogWrite("<------------------------------------End------------------------------------>")
