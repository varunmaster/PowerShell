$subtitleFiles = @(Get-ChildItem -Path "C:\Users\vm305\Desktop\subs\*" | Where-Object {$_ -like "*.srt"})


foreach($sub in $subtitleFiles){
    if([System.IO.Directory]::Exists("C:\Users\vm305\Desktop\Subtitles")){
        Copy-Item -Path $sub -Destination "C:\Users\vm305\Desktop\Subtitles"
     }
     else{
        New-Item -Path "C:\Users\vm305\Desktop\" -Name "Subtitles" -ItemType "Directory"
        Copy-Item -Path $sub -Destination "C:\Users\vm305\Desktop\Subtitles"
     }
}