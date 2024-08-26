$nowTime = $(get-date -f dd-MM-yy_hh-mm-ss)
$startTime = $(get-date -f dd-MM-yy_dddd_hh-mm-ss)
Start-Transcript -Path C:\Windows\Temp\sfc_$nowTime.log
##Write-Information "Script Started - $($startTime)"
##$regPath = "HKLM:\SOFTWARE\FSLogix\profiles"
$newArgument

try
{
##New-ItemProperty -Path $regPath -Name FlipFlopProfileDirectoryName -PropertyType DWORD -Value 1 -Force #| Out-Default -Transcript
Write-Information "Hello $($newArgument), how are you doing... Currently, the time is $($startTime)"
}
catch {}
##Write-Information "Script Completed" ##-Verbose
Stop-Transcript
