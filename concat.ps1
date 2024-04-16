$acb_in = ".\acb\in"
$acb_out = ".\acb\out"
$ext_wav = ".\extracted_hca"
$ext_adx = ".\extracted_adx"
$rep_in = ".\replacements"
$rep_enc = ".\temp"

function Convert-Timecode {
    param (
        [int]$Milliseconds
    )

    # Convert milliseconds to seconds
    $Seconds = [math]::Floor($Milliseconds / 1000)

    # Calculate remaining milliseconds
    $RemainingMilliseconds = $Milliseconds % 1000

    # Calculate minutes
    $Minutes = [math]::Floor($Seconds / 60)

    # Calculate remaining seconds
    $RemainingSeconds = $Seconds % 60

    # Format the output
    $TimeFormat = '{0:mm\:ss\.fff}' -f ([datetime]'00:00:00').AddMinutes($Minutes).AddSeconds($RemainingSeconds).AddMilliseconds($RemainingMilliseconds)
    
    return $TimeFormat
}

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
cd  $scriptPath

if ((Test-Path ".\bin\sox") -eq $false) {
    if ((Test-Path -Path ".\download") -eq $false) { New-Item -Path ".\download" -ItemType Directory }
    if (Test-Path ".\download\sox\") {
        Remove-Item -Path ".\download\sox\" -Recurse -Force -Confirm:$false
    }
    $url = "https://gigenet.dl.sourceforge.net/project/sox/sox/14.4.2/sox-14.4.2-win32.zip"
    New-Item -ItemType Directory -Path ".\download\sox" -ErrorAction SilentlyContinue
    Invoke-WebRequest -UseBasicParsing -Uri $url  -OutFile ".\download\sox\out.zip"
    Expand-Archive -Path ".\download\sox\out.zip" -DestinationPath ".\download\sox\out-zip"
    Move-Item -Path ".\download\sox\out-zip\sox-*" -Destination ".\bin\sox"
}
if (Test-Path -Path ".\download") { Remove-Item -Path ".\download" -Recurse -Force -Confirm:$false }

# Get ACB Base Name
$projectName = (Get-ChildItem -Path "${acb_out}\*.acb")[0].BaseName
Write-Host "Project: ${projectName}"

cd ${ext_wav}
& "..\bin\sox\sox.exe" '.\*.wav' .\..\concat-output.wav
cd ..

if (Test-Path -Path ".\concat-timecodes.txt") { Remove-Item -Path ".\concat-timecodes.txt" -Force -Confirm:$false }
if (Test-Path -Path ".\concat-timecodes.csv") { Remove-Item -Path ".\concat-timecodes.csv" -Force -Confirm:$false }
New-Item -ItemType File -Path .\concat-timecodes.txt
New-Item -ItemType File -Path .\concat-timecodes.csv
Set-Content -Path  .\concat-timecodes.csv -Value "Name`tStart`tDuration`tTime`tFormat`tType`tDescription"

$timecode = 0;
Get-ChildItem "${ext_wav}\*.wav" | ForEach-Object {
    Write-Host "Generate Timecodes for $($_.BaseName).wav"
    $durationMs = ./bin/ffmpeg -i $($_.FullName) 2>&1 | Select-String "Duration" | ForEach-Object { $_ -match "Duration: (\d+:\d+:\d+\.\d+)" | Out-Null; $matches[1] }
    $durationMs = [TimeSpan]::Parse($durationMs).TotalMilliseconds
    Add-Content -Path .\concat-timecodes.txt -Value "$($_.BaseName) $durationMs"
    Add-Content -Path  .\concat-timecodes.csv -Value "$($_.BaseName)`t$(Convert-Timecode -milliseconds $timecode)`t$(Convert-Timecode -milliseconds $durationMs)`tdecimal`tCue`tAutomated Cue Point"
    $timecode = $timecode + $durationMs
}