Write-Information "Creating directory on PC...."
$dirName = "$env:SystemDrive\3m-Temp"
New-Item -ItemType Directory -Force -Path $dirName
Start-Transcript -Path $dirName\3m_CustomScripts.log -Append
try
{
Write-Information "Creating directory on PC...."
    $dirName = "$env:SystemDrive\3m-Temp"
    New-Item -ItemType Directory -Force -Path $dirName
    $preferLanguage = 'en-AU'
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
    
    Write-Information "`t==================================================`
    All the settings has been updated successfully....`
    Please restart your computer for updated settings...`
    =================================================="
	
	Write-Information "The Script has finished."

    }
    catch{}
    Stop-Transcript