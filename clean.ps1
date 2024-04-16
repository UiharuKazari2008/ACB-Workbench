$acb_in = ".\acb\in"
$acb_out = ".\acb\out"
$ext_wav = ".\extracted_hca"
$ext_adx = ".\extracted_adx"
$rep_in = ".\replacements"
$dec_out = ".\extracted_transform"
$rep_enc = ".\temp"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
cd  $scriptPath

Write-Host "Project will be cleared in 5 secounds! Press CTRL + C to abort"
Sleep -Seconds 5

Remove-Item -Recurse -Force -Confirm:$false -Path "${ext_wav}"
Remove-Item -Recurse -Force -Confirm:$false -Path "${ext_adx}"
Remove-Item -Recurse -Force -Confirm:$false -Path "${rep_enc}"
Remove-Item -Force -Confirm:$false -Path "${acb_in}\*.acb"
Remove-Item -Force -Confirm:$false -Path "${acb_in}\*.awb"
Remove-Item -Recurse -Force -Confirm:$false -Path "${acb_out}*"
Remove-Item -Recurse -Force -Confirm:$false -Path "${dec_out}*"
Remove-Item -Recurse -Force -Confirm:$false -Path ".\download"
Remove-Item -Recurse -Force -Confirm:$false -Path ".\concat-timecodes.txt"
Remove-Item -Recurse -Force -Confirm:$false -Path ".\concat-output.wav"
Remove-Item -Recurse -Force -Confirm:$false -Path ".\transform.wav"

Write-Host "Project Cleared!"
Sleep -Seconds 5