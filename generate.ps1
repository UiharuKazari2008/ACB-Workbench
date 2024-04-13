# Refer to https://github.com/vgmstream/vgmstream/blob/master/src/meta/hca_keys.h (Line 1177 in the comment not the code)
# The keys from there are backwards so the first 8 HEX are key1 and the last 8 HEX are key0
$key0 = "CE264700"
$key1 = "0074FF1F"

$acb_key = ".\acb\key.ps1"
$acb_in = ".\acb\in"
$acb_out = ".\acb\out"
$ext_wav = ".\extracted"

$rep_in = ".\replacements"
$rep_enc = ".\temp"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
cd  $scriptPath

if ((Test-Path "${acb_in}") -eq $false) { New-Item -ItemType Directory -Path "${acb_in}" }
if ((Test-Path "${acb_out}") -eq $false) { New-Item -ItemType Directory -Path "${acb_out}" }
if ((Test-Path "${ext_wav}") -eq $false) { New-Item -ItemType Directory -Path "${ext_wav}" }
if ((Test-Path "${rep_in}") -eq $false) { New-Item -ItemType Directory -Path "${rep_in}" }
if ((Test-Path ".\bin\") -eq $false) { New-Item -ItemType Directory -Path ".\bin" }

if ((Test-Path ${acb_in}) -eq $false) {
    New-Item -ItemType Directory -Path ${acb_in}
}
if ((Test-Path ${acb_out}) -eq $false) {
    New-Item -ItemType Directory -Path ${acb_out}
}
if ((Test-Path ${ext_wav}) -eq $false) {
    New-Item -ItemType Directory -Path ${ext_wav}
}
if ((Test-Path ${rep_in}) -eq $false) {
    New-Item -ItemType Directory -Path ${rep_in}
}
if ((Test-Path ${rep_enc}) -eq $false) {
    New-Item -ItemType Directory -Path ${rep_enc}
}

# Check for ACB
if ((Test-Path -Path "${acb_out}\*.acb") -eq $false) {
    Write-Error "No ACB+AWB Files were found in \acb\in\"
    Read-Host "Press Return to Exit"
    throw "No ACBs"
}

# Get ACB Base Name
$projectName = (Get-ChildItem -Path "${acb_out}\*.acb")[0].BaseName
Write-Host "Project: ${projectName}"
if ((Test-Path -Path "${acb_out}\${projectName}") -eq $false) { 
    Write-Error "No Project folder was found, Run Extract first"
    Read-Host "Press Return to Exit"
    throw "No project folder"
}

# Encode ACB
if ((Test-Path -Path "${rep_in}\*.wav") -eq $false) { throw "No Files to replace" }
if ((Test-Path "${rep_enc}") -eq $false) { New-Item -ItemType Directory -Path "${rep_enc}" }
Get-ChildItem "${rep_in}\*.wav" | ForEach-Object {
    Write-Host "Encode and Encrypt: $($_.BaseName).wav"
    & ".\bin\deretore-toolkit\hcaenc.exe" "$($_.FullName)" "${rep_enc}\$($_.BaseName).hca" -q 1
    & ".\bin\deretore-toolkit\hcacc.exe" "${rep_enc}\$($_.BaseName).hca" "${acb_out}\${projectName}\$($_.BaseName).hca" -ot 56 -o1 $key0 -o2 $key1
}

Remove-Item -Path "${rep_enc}\*.hca" -Confirm:$false

Write-Host "Generate ACB File...."
Start-Process -Wait -PassThru -FilePath ".\bin\SonicAudioTools\AcbEditor.exe" -ArgumentList $(Resolve-Path "${acb_out}\${projectName}").Path

Copy-Item -Path "${acb_out}\${projectName}.acb" -Destination ".\" -Force
Copy-Item -Path "${acb_out}\${projectName}.awb" -Destination ".\" -Force