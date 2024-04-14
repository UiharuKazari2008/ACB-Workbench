$acb_in = ".\acb\in"
$acb_out = ".\acb\out"
$ext_wav = ".\extracted_wav"
$ext_adx = ".\extracted_adx"
$rep_in = ".\replacements"
$rep_enc = ".\temp"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
cd  $scriptPath

Write-Host "Project will be cleared in 5 secounds! Press CTRL + C to abort"
Sleep -Seconds 5

Remove-Item -Recurse -Force -Confirm:$false -Path "${ext_wav}"
Remove-Item -Recurse -Force -Confirm:$false -Path "${rep_enc}"
Remove-Item -Force -Confirm:$false -Path "${acb_in}\*.acb"
Remove-Item -Force -Confirm:$false -Path "${acb_in}\*.awb"
Remove-Item -Recurse -Force -Confirm:$false -Path "${acb_out}*"
Remove-Item -Recurse -Force -Confirm:$false -Path ".\download"

Write-Host "Project Cleared!"
Sleep -Seconds 5