# Refer to https://github.com/vgmstream/vgmstream/blob/master/src/meta/hca_keys.h (Line 1177 in the comment not the code)
# The keys from there are backwards so the first 8 HEX are key1 and the last 8 HEX are key0
$key0 = "CE264700"
$key1 = "0074FF1F"

$acb_in = ".\acb\in"
$acb_out = ".\acb\out"
$ext_wav = ".\extracted_hca"
$ext_adx = ".\extracted_adx"
$rep_in = ".\replacements"
$rep_enc = ".\temp"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
cd  $scriptPath

if ((Test-Path "${acb_in}") -eq $false) { New-Item -ItemType Directory -Path "${acb_in}" }
if ((Test-Path "${acb_out}") -eq $false) { New-Item -ItemType Directory -Path "${acb_out}" }
if ((Test-Path "${ext_wav}") -eq $false) { New-Item -ItemType Directory -Path "${ext_wav}" }
if ((Test-Path "${ext_adx}") -eq $false) { New-Item -ItemType Directory -Path "${ext_adx}" }
if ((Test-Path "${rep_in}") -eq $false) { New-Item -ItemType Directory -Path "${rep_in}" }
if ((Test-Path ".\bin\") -eq $false) { New-Item -ItemType Directory -Path ".\bin" }

if ((Test-Path ".\bin\deretore-toolkit") -eq $false) {
    if ((Test-Path -Path ".\download") -eq $false) { New-Item -Path ".\download" -ItemType Directory }
    if (Test-Path ".\download\deretore\") {
        Remove-Item -Path ".\download\deretore\" -Recurse -Force -Confirm:$false
    }
    $url = "https://github.com/OpenCGSS/DereTore/releases/download/all-v0.8.1-alpha/deretore-toolkit-v0.8.1.176-alpha-b176.zip"
    New-Item -ItemType Directory -Path ".\download\deretore" -ErrorAction SilentlyContinue
    Invoke-WebRequest -UseBasicParsing -Uri $url  -OutFile ".\download\deretore\out.zip"
    Expand-Archive -Path ".\download\deretore\out.zip" -DestinationPath ".\download\deretore\out-zip"
    Move-Item -Path ".\download\deretore\out-zip\Release" -Destination ".\bin\deretore-toolkit"
}
if ((Test-Path ".\bin\SonicAudioTools") -eq $false) {
    if ((Test-Path -Path ".\download") -eq $false) { New-Item -Path ".\download" -ItemType Directory }
    if ((Test-Path ".\download\7z") -eq $false) {
        $7z = "https://github.com/daemondevin/7-ZipPortable/archive/refs/heads/master.zip"
        Invoke-WebRequest -UseBasicParsing -Uri $7z  -OutFile ".\download\7z.zip"
        Expand-Archive -Path ".\download\7z.zip" -DestinationPath ".\download\7z"
    }
    
    if (Test-Path ".\download\sonic\") {
        Remove-Item -Path ".\download\sonic\" -Recurse -Force -Confirm:$false
    }

    # Hay stop packing your releases as a non-standard archive format, why not use RAR while your at it. Jesus
    $url = "https://github.com/blueskythlikesclouds/SonicAudioTools/releases/download/v1.0.1/SonicAudioTools.7z"
    New-Item -ItemType Directory -Path ".\download\sonic" -ErrorAction SilentlyContinue
    Invoke-WebRequest -UseBasicParsing -Uri $url  -OutFile ".\download\sonic\out.7z"
    & ".\download\7z\7-ZipPortable-master\App\7-Zip\7z.exe" x ".\download\sonic\out.7z" -o".\download\sonic\out-zip"
    Sleep -Seconds 3
    Move-Item -Path ".\download\sonic\out-zip" -Destination ".\bin\SonicAudioTools"
}
if (Test-Path -Path ".\download") { Remove-Item -Path ".\download" -Recurse -Force -Confirm:$false }


# Copy ACB/AWB to Work Folder
if ((Test-Path -Path "${acb_out}\*.acb") -eq $false) { Copy-Item -Path "${acb_in}\*.*" -Destination "${acb_out}\" }
# Check for ACB
if ((Test-Path -Path "${acb_out}\*.acb") -eq $false) { 
    Write-Error "No ACB+AWB Files were found in \acb\in\"
    Read-Host "Press Return to Exit"
    throw "No ACBs"
}

# Get ACB Base Name
$projectName = (Get-ChildItem -Path "${acb_out}\*.acb")[0].BaseName
Write-Host "Project: ${projectName}"

# Extract ACB
if ((Test-Path -Path "${acb_out}\${projectName}") -eq $false) {
    Write-Host "Extracting ACB File...."
    Start-Process -Wait -PassThru -FilePath ".\bin\SonicAudioTools\AcbEditor.exe" -ArgumentList $(Resolve-Path "${acb_out}\${projectName}.acb").Path
}
if ((Test-Path -Path "${acb_out}\${projectName}") -eq $false) { throw "ACB did not extract" }

Get-ChildItem "${acb_out}\${projectName}\*.hca" | ForEach-Object {
    if ((Test-Path -Path "${ext_wav}\$($_.BaseName).wav") -eq $false) {
        Write-Host "Extracted: $($_.BaseName).wav"
        & ".\bin\deretore-toolkit\hca2wav.exe" "$($_.FullName)" -a $key0 -b $key1 -o "${ext_wav}\$($_.BaseName).wav"
    }
}
Get-ChildItem "${acb_out}\${projectName}\*.adx" | ForEach-Object {
    if ((Test-Path -Path "${ext_adx}\$($_.BaseName).wav") -eq $false) {
        Write-Host "Extracted: $($_.BaseName).wav"
        & ".\bin\ffmpeg.exe" -y -loglevel fatal -hide_banner -nostats -i "$($_.FullName)" "${ext_adx}\$($_.BaseName).wav"
    }
}