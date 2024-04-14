$acb_in = ".\acb\in"
$acb_out = ".\acb\out"
$ext_wav = ".\extracted_wav"
$ext_adx = ".\extracted_adx"
$rep_in = ".\replacements"
$rep_enc = ".\temp"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
cd  $scriptPath

# Get ACB Base Name
$projectName = (Get-ChildItem -Path "${acb_out}\*.acb")[0].BaseName
Write-Host "Project: ${projectName}"

cd ${ext_wav}
& "C:\Program Files (x86)\sox-14-4-2\sox.exe" '.\*.wav' output.wav