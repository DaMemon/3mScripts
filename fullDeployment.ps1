param(
    [string]$secretValue
)

Write-Information "Creating directory on PC...."
##$dirName = "$env:SystemDrive\3m-Temp"
$dirName = "C:\Windows\Temp\3m-Temp"
New-Item -ItemType Directory -Force -Path $dirName
Start-Transcript -Path $dirName\3m_CustomScripts.log -Append
$localAccount = "3mlocaladmin"
try
{
Write-Information "Creating directory on PC...."
    ##$dirName = "C:\Windows\Temp\3m-Temp"
    ##New-Item -ItemType Directory -Force -Path $dirName
    $preferLanguage = 'en-AU'

    Write-Information "Getting all settings for Time zone, locale, country code, Region..."
    Get-WinSystemLocale
    Get-WinHomeLocation
    Get-TimeZone
    Get-WinUserLanguageList
    Get-Culture
    gwmi win32_operatingsystem | select locale, countrycode
    "=========================================="
    
	Write-Information "Setting System local to $preferLanguage.."
    Set-WinSystemLocale $preferLanguage
    Write-Information "System Locale has been changed..."
    ##Get-WinSystemLocale
    "__________________________________________"
    
	Write-Information "Setting Time Zone | AUS Eastern Standard Time... "
    Set-TimeZone -Id "AUS Eastern Standard Time"
    Write-Information "Time has been changed.... Getting updated information..."
    ##Get-TimeZone
    "||||||||||||||||||||||||||||||||||||||||||"
	
    Write-Information "Setting Region and Culture settings to Australia.."
    #Get-WinHomeLocation
    Set-WinHomeLocation -GeoID 12
    Write-Information "Region has been changed..."
    Set-Culture -CultureInfo $preferLanguage
    Write-Information "Culture info has been ... $preferLanguage"
    #Get-WinHomeLocation
    "------------------------------------------"
    
	$lngList = New-WinUserLanguageList $preferLanguage
    Set-WinUserLanguageList $lngList -Force
    Set-WinUILanguageOverride $preferLanguage
    Write-Information "Preferred language has been set to $preferLanguage"
    "*******************************************"

    Write-Information "Getting final settings for Time zone, locale, country code, Region..."
    Get-WinSystemLocale
    Get-WinHomeLocation
    Get-TimeZone
    Get-WinUserLanguageList
    Get-Culture
    gwmi win32_operatingsystem | select locale, countrycode
    
    $outFile = "$($dirName)\3m_Language.xml"
    
    $xmlStr = @"
<gs:GlobalizationServices xmlns:gs="urn:longhornGlobalizationUnattend">
    <!--User List-->
    <gs:UserList>
        <gs:User UserID="Current" CopySettingsToSystemAcct="true" CopySettingsToDefaultUserAcct="true" /> 
    </gs:UserList>

    <!--User Locale-->
    <gs:UserLocale> 
        <gs:Locale Name="$($preferLanguage)" SetAsCurrent="true" ResetAllSettings="true"/>
    </gs:UserLocale>

    <!-- system locale -->
        <gs:SystemLocale Name="$($preferLanguage)"/>

    <gs:MUILanguagePreferences>
        <gs:MUILanguage Value="$($preferLanguage)"/>
        <!--<gs:MUIFallback Value="en-US"/>-->
    </gs:MUILanguagePreferences>

    <gs:InputPreferences>
    <!--en-AU-->
    <gs:InputLanguageID Action="add" ID="0c09:00000409" Default="true"/> 
</gs:InputPreferences>


</gs:GlobalizationServices>
"@

    $xmlStr | Out-File $outFile -Force -Encoding ascii

    # Use this copy settings to system and default user 
    Write-Information "Copy language settings with control.exe for system and user accounts."
    & $env:SystemRoot\System32\control.exe "intl.cpl,,/f:""$($outFile)"""
   
    
    Write-Information "`t==================================================`
    All the settings has been updated successfully....`
    Please restart your computer for updated settings...`
    =================================================="

Write-Information "Adding users to FSLogix exclude group..."
Add-LocalGroupMember -Group "FSLogix Profile Exclude List" -Member $($localAccount)
## Add-LocalGroupMember -Group "FSLogix ODFC Exclude List" -Member $($localAccount)
Write-Information "Get Local user details..."
Get-LocalGroupMember -Group "FSLogix Profile Exclude List"


Write-Information "Configuring all required variables"
$fslogixLocation = "HKLM:\SOFTWARE\FSLogix"
$regPath = "HKLM:\SOFTWARE\FSLogix\profiles"
$regAppPath = "HKLM:\SOFTWARE\FSLogix\Apps"
$outlookonline = "HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\Outlook\OST"
$vhdLocation = "\\3mavdstgacc.file.core.windows.net\avdprofiles"
$storageAccountName="3mavdstgacc"
$fileServer="3mavdstgacc.file.core.windows.net"
$user="localhost\$storageAccountName"
$shareName="avdprofiles"
$profileShare="\\$fileServer\$shareName"
$secret=$secretValue
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LsaCfgFlags" -Value 0 -force

Write-Information "Configuring FSLogix all Cloud Settings by adding details to Windows Credential Manager."
cmd.exe /C "cmdkey /add:$($fileServer) /user:$($user) /pass:$($secret)"

Write-Information "Adding FSLogix registry key if it does not exist."
if((Test-Path -LiteralPath $fslogixLocation) -ne $true) {
"Reg Path $($fslogixLocation) does not exist `n creating new KEY - $fslogixLocation"
  New-Item $fslogixLocation -force }
  
Write-Information "Creating new key for Outlook"
if((Test-Path -LiteralPath $outlookonline) -ne $true) {
"Reg Path $($outlookonline) does not exist `n creating new KEY - $outlookonline"
  New-Item $outlookonline -force }
  
Write-Information "Enabling fslogix registry keys..."
New-ItemProperty -Path $regPath -Name Enabled -PropertyType DWORD -Value 1 -Force
New-ItemProperty -Path $regPath -Name VHDLocations -PropertyType MultiString -Value $vhdLocation -Force
New-ItemProperty -Path $regPath -Name IsDynamic -PropertyType DWORD -Value 1 -Force
New-ItemProperty -Path $regPath -Name DeleteLocalProfileWhenVHDShouldApply -PropertyType DWORD -Value 1 -Force
New-ItemProperty -Path $regPath -Name FlipFlopProfileDirectoryName -PropertyType DWORD -Value 1 -Force
New-ItemProperty -Path $regPath -Name LockedRetryCount -PropertyType DWORD -Value 3 -Force
New-ItemProperty -Path $regPath -Name LockedRetryInterval -PropertyType DWORD -Value 15 -Force
New-ItemProperty -Path $regPath -Name SizeInMBs -PropertyType DWORD -Value 30000 -Force
New-ItemProperty -Path $regPath -Name VolumeType -Value vhdx -PropertyType String -Force
New-ItemProperty -Path $regPath -Name PreventLoginWithFailure -PropertyType DWORD -Value 1 -Force
New-ItemProperty -Path $regPath -Name OutlookCachedMode -PropertyType DWORD -Value 1 -Force
New-ItemProperty -Path $regPath -Name PreventLoginWithTempProfile -PropertyType DWORD -Value 1 -Force
New-ItemProperty -Path $regPath -Name RemoveOrphanedOSTFilesOnLogoff -PropertyType DWORD -Value 1 -Force
#additional properties
##New-ItemProperty -Path $regPath -Name ProfileType -PropertyType DWORD -Value 0 -Force
New-ItemProperty -Path $regPath -Name KeepLocalDir -PropertyType DWORD -Value 0 -Force
# FOR 100% CLOUD ONLY
New-ItemProperty -Path $regPath -Name AccessNetworkAscomputerObject -PropertyType DWORD -Value 1 -Force
# Outlook Online Mode
New-ItemProperty -Path $outlookonline -Name NoOST -PropertyType DWORD -Value 2 -Force

# App registry settings
New-ItemProperty -Path $regAppPath -Name CleanupInvalidSessions -PropertyType DWORD -Value 1 -Force
New-ItemProperty -Path $regAppPath -Name RoamRecycleBin -PropertyType DWORD -Value 1 -Force
New-ItemProperty -Path $regAppPath -Name VHDCompactDisk -PropertyType DWORD -Value 1 -Force
<# ##
## Add local username in the fslogix exclude list
###
$userToAdd = "3mlocaladmin"
$groupToAdd = "FSLogix Profile Exclude List"
"Users list in group $($groupToAdd).."
"Adding user ($($userToAdd)) in the group..."
Add-LocalGroupMember -Group $groupToAdd -Member $userToAdd -ErrorAction Continue
"User list in the Group."
Get-LocalGroupMember -Group $groupToAdd
}
#>
	Write-Information "The Script has finished."
    }
    catch{}
    Stop-Transcript
