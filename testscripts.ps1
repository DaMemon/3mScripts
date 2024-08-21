$nowTime = $(get-date -f dd-MM-yy_hh-mm-ss)
$startTime = $(get-date -f dd-MM-yy_dddd_hh-mm-ss)
Start-Transcript -Path C:\Windows\Temp\sfc_$nowTime.log
Write-Information "Script Started - $($startTime)"
##$regPath = "HKLM:\SOFTWARE\FSLogix\profiles"
try
{
#New-ItemProperty -Path $regPath -Name FlipFlopProfileDirectoryName -PropertyType DWORD -Value 1 -Force #| Out-Default -Transcript
Write-Information "Adding users to FSLogix eclude group..."
Add-LocalGroupMember -Group "FSLogix Profile Exclude List" -Member "3mlocaladmin"
Add-LocalGroupMember -Group "FSLogix ODFC Exclude List" -Member "3mlocaladmin"
Write-Information "Get Local user details
Get-LocalGroupMember -Group "FSLogix Profile Exclude List"
Write-Information "Setting up Cred manager
$fileserver="myServer"
$user="sfadmin"
$secret="Zora#4752@"
Write-Information "Configuring FSLogix all Cloud Settings by adding details to Windows Credential Manager."
cmd.exe /C "cmdkey /add:$($fileServer) /user:$($user) /pass:$($secret)"
}
catch {}
##Write-Information "Script Completed" ##-Verbose
Stop-Transcript
