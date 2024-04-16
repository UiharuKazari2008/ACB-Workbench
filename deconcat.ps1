$acb_in = ".\acb\in"
$acb_out = ".\acb\out"
$ext_wav = ".\extracted_hca"
$ext_adx = ".\extracted_adx"
$rep_in = ".\replacements"
$dec_out = ".\extracted_transform"
$rep_enc = ".\temp"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
cd  $scriptPath

if ((Test-Path ${dec_out}) -eq $false) {
    New-Item -ItemType Directory -Path ${dec_out}
}

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

if ((Test-Path -Path ".\concat-timecodes.txt") -eq $false) { 
    Write-Error "No Timecode sheet"
    Read-Host "Press Return to Exit"
    throw "No ACBs"
}
if ((Test-Path -Path ".\transform.wav") -eq $false) { 
    Write-Error "No Transformed Output"
    Read-Host "Press Return to Exit"
    throw "No Input WAV"
}

$timecode = 0;
Get-Content -Path ".\concat-timecodes.txt" | ForEach-Object {
    $conts = $_ -split " "
    $length = [Int]::Parse($conts[1])
    $endcode = $timecode + $length
    Write-Host "FileName: $($conts[0]) Start: $timecode Length: $endCode"
    .\bin\sox\sox.exe .\transform.wav "$dec_out\$($conts[0]).wav" trim ($timecode / 1000) ($length / 1000)
    $timecode = $timecode + $length
}