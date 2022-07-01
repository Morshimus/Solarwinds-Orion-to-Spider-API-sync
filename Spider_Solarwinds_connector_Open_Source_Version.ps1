# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

############################################################################################################
#               Developed by Daniel Dalavurak as powershell script for Windows Server.                     #
#                       Including functions and PS Modules like sqlserver                                  #
#                                       MIT License                                                        #              
############################################################################################################

# PARAMETERS:
# - spiderUser - Adminsitrative user to login via Spider API link.
# - spiderPass - Spider API user password.
# - spiderApiBaseUri - https link to SpiderAPI
# - Country - Country name, also value should be exist at Spider and at Solarwinds CP 
# - SQLDatabase - Name of Solarwinds Orion SQL Database
# - SQLServerInstance - Name of SW Orion SQL Server Instance
# - SQLUsername - Name of user, which has sysadmin access to SW Orion Database
# - SQLPassword - Password of user with sysadmin access to SW Orion Database
# - ReportNumber - Report number at Spider Application. Report should be sorted out by Switch Assets\Function Units. Check req table.
# - AssetNumberReg - Regular expression for filtered Assets by your naming convention.
#=======================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================================
# >FUNCTION _Main_:
#  Banner function, which consist squnced list of procedure functions. Function use all existing parameters which is required for functions. 
#  Included Functions: Sync-AssetsFromSpiderToSW, Populate-SWDatabaseNewFunctionUnitID, Populate-SWDatabaseNewAssetsID, Populate-SpiderLocations, Populate-FunctionUnits, Populate-SpiderAssetsModelSWChassis, Populate-SpiderAssetsModelSWModuleCard, Populate-SpiderAssetsModelSWPowerSupply, Populate-SpiderAssetsModelSWSSD, Populate-SpiderAssetsModelSecurityDevice, Populate-AssetUnits, Update-FunctionUnitsLocations, Update-AssetUnitsFunctionUnitID, Update-AssetUnitsSoftwareVersion, Update-UnitsStatus
#  Required parameters  same as common.
#
# >FUNCTION Get-SpiderSwitches:
#  Function which requested data from Spider certain reports.
#  Report should consist only Network devices Function Units and Assets - that should be LEFT join table.
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI, Country, ReportNu,ber
#
# >FUNCTION Get-SwitchesLocations:
#  Function to getting Location data from Spider '/0/search/Location' path with filter Arguments.
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI, Country
#
#
# >FUNCTION Get-SwitchesLegalEntity:
#  Function to getting Legal Enities data from Spider '/0/search/LegalEntity' path with filter Arguments.
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI, Country
#
#
# >FUNCTION Get-SwitchesAssetsChassisModel:
#  Function to getting Assets Chassis Models data from Spider '/0/search/Switch chassisTemplate' path with filter Arguments.
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI
#
#
# >FUNCTION Get-SwitchesAssetsModuleCardModel:
#  Function to getting Assets Module Cards Models data from Spider '/0/search/Switch module cardTemplate' path with filter Arguments.
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI
#
#
# >FUNCTION Get-SwitchesAssetsPowerSupplyModel:
#  Function to getting Assets Power Supply Models data from Spider '/0/search/Switch power supplyTemplate' path with filter Arguments.
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI
#
#
# >FUNCTION Get-SwitchesAssetsSSDModel:
#  Function to getting Assets SSD Models data from Spider '/0/search/Switch SSDTemplate' path with filter Arguments.
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI
#
#
# >FUNCTION Get-SwitchesAssetsSecurityDeviceModel:
#  Function to getting Assets Security Device Models data from Spider '/0/search/Security DeviceTemplate' path with filter Arguments.
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI
#
#
# >FUNCTION Get-FromattedSWList:
#  Function to get joined data from Solarwinds Orion database. Customizable query depends on your needs. Returning fromatted Powershell table type.
#  Required parameters SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword
#
#
# >FUNCTION Get-FunctionUnitFromattedList:
#  Function to sorted out by Spider's Function Unit info style, use Get-FromattedSWList function to get list . Returning Spider's Formated Function Unit Powershell table.
#  Required parameters SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword
#
#
# >FUNCTION Get-AssetUnitFromattedList:
#  Function to sorted out by Spider's Asset Unit info style, use   Get-FromattedSWList function to get list . Returning Spider's Formated Function Unit Powershell table.
#  Required parameters SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword
#
#
# >FUNCTION Add-SpiderLocation:
#  Function to create new Spider Location using POST method.
#  Required parametrts spiderUser, spiderPassword, spiderAPIbaseURI, Country, City, Street\Building, Floor, Room
#
#
# >FUNCTION Add-SpiderSwitchFunctionUnit:
#  Function to create new Switch Function Unit at Spider using POST method.
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI, Fu (Function unit ID name), Name(hostname), IP_address, LocID(Spider Location ID), LegID (Legal Entity ID), BU(Business unit Abbreviation)
#
#
# >FUNCTION Add-SpiderSwitchAssetsChassisModel:
#  Function to create new Asset Chassis Model at Spider using POST method.
#  Required parameters  spiderUser, spiderPassword, spiderAPIbaseURI, Model.
# 
#
# >FUNCTION Add-SpiderSwitchAssetsModuleCardModel:
#  Function to create new Asset Module Card Model at Spider using POST method.
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI, Model.
#
#
# >FUNCTION Add-SpiderSwitchAssetsPowerSupplyModel:
#  Function to create new Asset Switch Power Supply Model at Spider using POST method.
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI, Model.
#
#
# >FUNCTION Add-SpiderSwitchAssetsSSDModel:
#  Function to create new Asset Switch SSD Model at Spider using POST method.
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI, Model.
#
#
# >FUNCTION Add-SpiderSwitchAssetsSecurityDeviceModel:
#  Function to create new Asset Security Device Model at Spider using POST method.
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI, Model.
#
#
# >FUNCTION Sync-AssetsFromSpiderToSW:
#  Function to create synchronize Current existing Assets at Spider DB to Solarwinds DB filterd by equal serial numbers.
#  Included Functions: Get-SpiderSwitches
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, AssetNumberReg, ReportNumber, Country
#
#
# >FUNCTION Populate-SWDatabaseNewAssetsID:
#  Function to assign new asset id according Last asset ID for new NCM entity id in Solarwinds DB.
#  Included Functions: Get-SpiderSwitches, Write-Log
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, ReportNumber, Country
#
#
# >FUNCTION Populate-SWDatabaseNewFunctionUnitID:
#  Function to assign new Function Unit id according Last Function Unit ID for new NPM node id in Solarwinds DB.
#  Included Functions: Get-SpiderSwitches, Write-Log
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, ReportNumber, Country
#
#
# >FUNCTION Populate-SpiderLocations:
#  Function to populate absent location at Spider Side. Location value is taken from SNMP location of devices.
#  In this sorting function use sequnces for value, should be like: "Country/City/Street&Building/Floor/Room". If conditions meat, it will sorted out automatically.
#  Street&Building - couldn't be more that 50 characters.
#  Included Functions: Add-SpiderLocation,Get-FunctionUnitFromattedList,Get-SwitchesLocations, Write-Log
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, Country
#
#
# >FUNCTION Populate-FunctionUnits:
#  Function to upload formatted data to Spider using POST method. if it's not existing.
#  Included Functions: Add-SpiderSwitchFunctionUnit,Get-FunctionUnitFromattedList,Get-SwitchesLegalEntity, Get-SwitchesLocations,Get-SpiderSwitches,Write-Log
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, ReportNumber, Country
#
#
# >FUNCTION Populate-AssetUnits
#  Function to upload formatted data to Spider using POST method. If it's not existing.
#  Included Functions: Add-SpiderSwitchAssetUnit,Get-AssetUnitFromattedList, Get-SpiderSwitches, Write-Log
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, AssetNumberReg, ReportNumber, Country
#
#
# >FUNCTION Populate-SpiderAssetsModelSWChassis:
#  Function to upload formatted data to Spider using POST method. If it's not existing.
#  Included Functions: Add-SpiderSwitchAssetsChassisModel,Get-AssetUnitFromattedList,Get-SwitchesAssetsChassisModel, Write-Log
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, Country
#
#
# >FUNCTION Populate-SpiderAssetsModelSWModuleCard:
#  Function to upload formatted data to Spider using POST method. If it's not existing.
#  Included Functions:Get-AssetUnitFromattedList, Get-SwitchesAssetsModuleCardModel,Add-SpiderSwitchAssetsModuleCardModel, Write-Log
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, Country
#
#
# >FUNCTION Populate-SpiderAssetsModelSWPowerSupply:
#  Function to upload formatted data to Spider using POST method. If it's not existing.
#  Included Functions: Get-AssetUnitFromattedList, Get-SwitchesAssetsModuleCardModel,Add-SpiderSwitchAssetsPowerSupplyModel, Write-Log
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, Country
#
#
# >FUNCTION Populate-SpiderAssetsModelSWSSD:
#  Function to upload formatted data to Spider using POST method. If it's not existing.
#  Included Functions: Get-AssetUnitFromattedList, Get-SwitchesAssetsModuleCardModel,Add-SpiderSwitchAssetsSSDModel, Write-Log
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, Country
#
#
# >FUNCTION Populate-SpiderAssetsModelSecurityDevice:
#  Function to upload formatted data to Spider using POST method. If it's not existing.
#  Included Functions: Get-AssetUnitFromattedList, Get-SwitchesAssetsModuleCardModel,Add-SpiderSwitchAssetsSecurityDeviceModel, Write-Log
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, Country
#
#
# >FUNCTION Update-FunctionUnitsLocations:
#  Function to check Function Units locations and update it if not matching. Using PUT method.
#  Included Functions: Get-SwitchesLocations, Get-FunctionUnitFromattedList,Get-SpiderSwitches, Write-Log
#  Required parameters  spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, Country, AssetNumberReg, ReportNumber
#
#
# >FUNCTION Update-AssetUnitsFunctionUnitID
#  Function to check Asset Unit's Function ID bindings, if it was changed, change it in Spider system. Using PUT method.
#  Including Functions: Get-AssetUnitFromattedList, Get-SpiderSwitches, Write-Log
#  Required parameters  spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, Country, AssetNumberReg, ReportNumber
#
#
# >FUNCTION Update-AssetUnitsSoftwareVersion:
#  Function to check Assets Software version field. That field is custom for Spider Assets, so you need to create that field first before executing function. Field:"software version".
#  Including Functions: Get-AssetUnitFromattedList, Get-SpiderSwitches, Write-Log
#  Required parameters  spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, Country, AssetNumberReg, ReportNumber
#
#
# >FUNCTION Update-UnitsStatus:
#  Function to check is a system active in Solarwinds Orion and at Spider, if not matching updating value. Status of absent assets in Solarwinds is "in stock", for active "active".
#  Including Functions: Get-AssetUnitFromattedList, Get-FunctionUnitFromattedList, Get-SpiderSwitches, Write-Log
#  Required parameters spiderUser, spiderPassword, spiderAPIbaseURI,SQLDatabase, SQLServerInstance, SQLUsername, SQLPassword, Country, AssetNumberReg, ReportNumber
#
# >FUNCTION Write-Log:
#  Function to create log file in the same folder were script located. File has view like: Spider_Solarwinds_Sync_$($Country)_$(Get-date -f dd_MM_yyyy).txt where Country is Country and get date current date.
#  
#
#



Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ReportNumber,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$AssetNumberReg
        

)



function _Main_{

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ReportNumber,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$AssetNumberReg
        

)


ipmo sqlserver

Sync-AssetsFromSpiderToSW -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country  -ReportNumber $ReportNumber -AssetNumberReg $AssetNumberReg

Populate-SWDatabaseNewFunctionUnitID -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country -ReportNumber $ReportNumber

Populate-SWDatabaseNewAssetsID -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country -ReportNumber $ReportNumber

Populate-SpiderLocations -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country 

Populate-FunctionUnits -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country -ReportNumber $ReportNumber

Populate-SpiderAssetsModelSWChassis -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country 

Populate-SpiderAssetsModelSWModuleCard -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country 

Populate-SpiderAssetsModelSWPowerSupply -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country  

Populate-SpiderAssetsModelSWSSD -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country 

Populate-SpiderAssetsModelSecurityDevice -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country 

Populate-AssetUnits -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country -AssetNumberReg $AssetNumberReg -ReportNumber $ReportNumber 

Update-FunctionUnitsLocations -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country  -AssetNumberReg $AssetNumberReg -ReportNumber $ReportNumber

Update-AssetUnitsFunctionUnitID -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country  -AssetNumberReg $AssetNumberReg -ReportNumber $ReportNumber

Update-AssetUnitsSoftwareVersion -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country -AssetNumberReg $AssetNumberReg -ReportNumber $ReportNumber

Update-UnitsStatus -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country  -AssetNumberReg $AssetNumberReg -ReportNumber $ReportNumber 
}


function Get-SpiderSwitches {
Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ReportNumber
        

)



[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")

$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")


$spiderSwitchReportListUri = "/0/report/$($ReportNumber)?Orderby=Asset Number&MaxRows=100000&condition=AND|country|like|%25$Country&CultureCode=en-US"

$spiderSwitchReportListJson = Invoke-WebRequest -Uri "$spiderApiBaseUri$spiderSwitchReportListUri" -Headers $spiderHeader -Method Get -ContentType "application/json"

$spiderSwitchReportList = $spiderSwitchReportListJson.Content | ConvertFrom-Json

$spiderSwitchReportObject = $spiderSwitchReportList.result

return $spiderSwitchReportObject

}

function Get-SwitchesLocations {
Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country
        

)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 


$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")

$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")

$spiderLocationsUri = "/0/search/Location?MaxRows=100000&AllFields=True&condition=AND|country|like|$Country%25&CultureCode=en-US"
$spiderLocationsList = Invoke-WebRequest -Uri "$spiderApiBaseUri$spiderLocationsUri" -Headers $spiderHeader -Method Get -ContentType "application/json"

$spiderLocationsListAsJson = $spiderLocationsList.Content | ConvertFrom-Json

$spiderLocationsObject = $spiderLocationsListAsJson.result

return $spiderLocationsObject

}

function Get-SwitchesLegalEntity {
Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country
        

)


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")

$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")

$spiderLegalEntityUri = "/0/search/LegalEntity?Orderby=Description&MaxRows=100000&AllFields=True&condition=AND|country|like|%25$Country&CultureCode=en-US"
$spiderLegalEntityList = Invoke-WebRequest -Uri "$spiderApiBaseUri$spiderLegalEntityUri" -Headers $spiderHeader -Method Get -ContentType "application/json"

$spiderLegalEntityListAsJson = $spiderLegalEntityList.Content | ConvertFrom-Json

$spiderLegalEntityObject = $spiderLegalEntityListAsJson.result

return $spiderLegalEntityObject

}

function Get-SwitchesAssetsChassisModel {
Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri
        

)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")

$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")

$spiderAssetsSwitchChassisUri = "/0/search/Switch chassisTemplate?Orderby=sysTemplateActive&MaxRows=1000000&AllFields=True&CultureCode=en-US"
$spiderAssetsSwitchChassisList = Invoke-WebRequest -Uri "$spiderApiBaseUri$spiderAssetsSwitchChassisUri" -Headers $spiderHeader -Method Get -ContentType "application/json"

$spiderAssetsSwitchChassisListAsJson = $spiderAssetsSwitchChassisList.Content | ConvertFrom-Json

$spiderAssetsSwitchChassisObject = $spiderAssetsSwitchChassisListAsJson.result

return $spiderAssetsSwitchChassisObject

}

function Get-SwitchesAssetsModuleCardModel {
Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri
        

)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")

$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")

$spiderAssetsModuleCardUri = "/0/search/Switch module cardTemplate?MaxRows=1000000&AllFields=True&CultureCode=en-US"
$spiderAssetsModuleCardList = Invoke-WebRequest -Uri "$spiderApiBaseUri$spiderAssetsModuleCardUri" -Headers $spiderHeader -Method Get -ContentType "application/json"

$spiderAssetsModuleCardListAsJson = $spiderAssetsModuleCardList.Content | ConvertFrom-Json

$spiderAssetsModuleCardObject = $spiderAssetsModuleCardListAsJson.result

return $spiderAssetsModuleCardObject

}


function Get-SwitchesAssetsPowerSupplyModel {
Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri
        

)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")

$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")

$spiderAssetsPowerSupplyUri = "/0/search/Switch power supplyTemplate?Orderby=sysTemplateActive&MaxRows=1000000&AllFields=True&CultureCode=en-US"
$spiderAssetsPowerSupplyList = Invoke-WebRequest -Uri "$spiderApiBaseUri$spiderAssetsPowerSupplyUri" -Headers $spiderHeader -Method Get -ContentType "application/json"

$spiderAssetsPowerSupplyListAsJson = $spiderAssetsPowerSupplyList.Content | ConvertFrom-Json

$spiderAssetsPowerSupplyObject = $spiderAssetsPowerSupplyListAsJson.result

return $spiderAssetsPowerSupplyObject

}


function Get-SwitchesAssetsSSDModel {
Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri
        

)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")

$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")

$spiderAssetsSSDUri = "/0/search/Switch SSDTemplate?Orderby=sysTemplateActive&MaxRows=1000000&AllFields=True&CultureCode=en-US"
$spiderAssetsSSDList = Invoke-WebRequest -Uri "$spiderApiBaseUri$spiderAssetsSSDUri" -Headers $spiderHeader -Method Get -ContentType "application/json"

$spiderAssetsSSDListAsJson = $spiderAssetsSSDList.Content | ConvertFrom-Json

$spiderAssetsSSDObject = $spiderAssetsSSDListAsJson.result

return $spiderAssetsSSDObject

}

function Get-SwitchesAssetsSecurityDeviceModel {
Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri
        

)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")

$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")

$spiderAssetsSecurityDeviceUri = "/0/search/Security DeviceTemplate?Orderby=sysTemplateActive&MaxRows=1000000&AllFields=True&CultureCode=en-US"
$spiderAssetsSecurityDeviceList = Invoke-WebRequest -Uri "$spiderApiBaseUri$spiderAssetsSecurityDeviceUri" -Headers $spiderHeader -Method Get -ContentType "application/json"

$spiderAssetsSecurityDeviceListAsJson = $spiderAssetsSecurityDeviceList.Content | ConvertFrom-Json

$spiderAssetsSecurityDeviceObject = $spiderAssetsSecurityDeviceListAsJson.result

return $spiderAssetsSecurityDeviceObject

}

function Get-FromattedSWList {
Param(       
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword
)

$query = @"
Select n.Spider_Function_Unit, n.SysName, p.Model, p.Class, p.AssetID, p.Serial, p.HardwareRevision, p.SoftwareRevision, n.SysLocation, n.Department, n.AgentIP, n.Region, n.Business_Unit, n.LTN, n.Status as Maintenance  from SolarWindsOrion.dbo.NCM_Nodes as n

Left join SolarWindsOrion.dbo.NCM_Entity_Physical as p on n.NodeID = p.NodeID
where  n.country = '$Country' and n.Carrier_Name is NULL  and (p.Class = 'module(9)' or p.Class = 'chassis(3)' or p.Class = 'powersupply(6)') and not p.Serial = '' and not p.Model = '' 
"@

$SQLSWList = Invoke-Sqlcmd -query $query -Database $SQLDatabase -ServerInstance $SQLServerInstance -Username $SQLUsername -Password $SQLPassword
$SQLSWList | ? {$_.Serial -like "V0[0-9]"} | % {$_.Serial = $_.HardwareRevision}
$SQLSWList | ? {$_.Model -like "SSD*"} | % {$_.Class = "Switch SSD"}
$SQLSWList | ? {$_.Model -like "ASA*"} | % {$_.Class = "Security device"}
$SQLSWList | ? {$_.Class -like "module(9)"} | % {$_.Class = "Switch module card"}
$SQLSWList | ? {$_.Class -like "powerSupply(6)"} | % {$_.Class = "Switch power supply"}
$SQLSWList | ? {$_.Class -like "chassis(3)"} | % {$_.Class = "Switch chassis"}

return $SQLSWList
}

function Get-FunctionUnitFromattedList {

Param ( 

        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword
        

)



$SQLSWList = Get-FromattedSWList -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -Country $Country -SQLUsername $SQLUsername -SQLPassword $SQLPassword

$FU = ($SQLSWList | Select -exp "Spider_Function_Unit" | Select -Unique )
$Names = $SQLSWList | % {$_.SysName  -replace '\.[a-z\.]*', ''} | Select -uniq
$Locations = Foreach($Name in $Names){$SQLSWList| ? {$_.SysName -like $Name+"*"}|Select -Unique|Select -exp SysLocation}
$Departments = Foreach($Name in $Names){$SQLSWList| ? {$_.SysName -like $Name+"*"}|Select -Unique|Select -exp Department}
$Region = Foreach($Name in $Names){$SQLSWList| ? {$_.SysName -like $Name+"*"}|Select -Unique|Select -exp Region}
$IP = Foreach($Name in $Names){$SQLSWList| ? {$_.SysName -like $Name+"*"}|Select -Unique|Select -exp AgentIP}
$BU = Foreach($Name in $Names){$SQLSWList| ? {$_.SysName -like $Name+"*"}|Select -Unique|Select -exp Business_Unit}
$Maintenance = Foreach($Name in $Names){IF(($SQLSWList| ? {$_.SysName -like $Name+"*"}|Select -Unique|Select -exp Maintenance) -eq 9){"15"}else{"14"}} 
$FU_Table = @()

If($FU.GetType().Name -like "String"){$item= New-Object PSObject; $item |add-member -type NoteProperty -Name 'Name' -Value $Names;$item | add-member -type NoteProperty -Name 'Function Unit' -Value $FU;$item | add-member -type NoteProperty -Name 'Legal Entity' -Value $Departments;$item |add-member -type NoteProperty -Name 'Location' -Value $Locations;$item |add-member -type NoteProperty -Name 'Region' -Value $Region;$item |add-member -type NoteProperty -Name 'IP' -Value $IP;$item |add-member -type NoteProperty -Name 'Business Unit' -Value $BU;$item |add-member -type NoteProperty -Name 'Maintenance' -Value $Maintenance; $FU_Table += $item}else{
for($x=0;$x -lt $FU.Count;$x++){$item= New-Object PSObject; $item |add-member -type NoteProperty -Name 'Name' -Value $Names[$x];$item | add-member -type NoteProperty -Name 'Function Unit' -Value $FU[$x];$item | add-member -type NoteProperty -Name 'Legal Entity' -Value $Departments[$x];$item |add-member -type NoteProperty -Name 'Location' -Value $Locations[$x];$item |add-member -type NoteProperty -Name 'Region' -Value $Region[$x];$item |add-member -type NoteProperty -Name 'IP' -Value $IP[$x];$item |add-member -type NoteProperty -Name 'Business Unit' -Value $BU[$x];$item |add-member -type NoteProperty -Name 'Maintenance' -Value $Maintenance[$x]; $FU_Table += $item}
}
return $FU_Table

}

function Get-AssetUnitFromattedList {

Param ( 

        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword
        

)

$SQLSWList = Get-FromattedSWList -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -Country $Country -SQLUsername $SQLUsername -SQLPassword $SQLPassword

$Assets = ($SQLSWList | Select -exp "Assetid")
$Function_Unit = $SQLSWList | Select -exp Spider_Function_Unit
$Serial = $SQLSWList | Select -exp Serial
$Hostname = ($SQLSWList | Select -exp SysName) -replace '\.[a-z\.]*', ''
$Class = $SQLSWList | Select -exp Class
$Model = $SQLSWList | Select -exp Model 
$SoftwareVersion = $SQLSWList | Select -exp SoftwareRevision

$Assets_Table = @()
if($Assets.GetType().Name -like "String"){$item= New-Object PSObject;$item |add-member -type NoteProperty -Name 'SoftwareVersion' -Value $SoftwareVersion;$item |add-member -type NoteProperty -Name 'AssetID' -Value $Assets ;$item |add-member -type NoteProperty -Name 'Hostname' -Value $Hostname;$item | add-member -type NoteProperty -Name 'Function Unit' -Value $Function_Unit;$item | add-member -type NoteProperty -Name 'Serial' -Value $Serial;$item |add-member -type NoteProperty -Name 'Class' -Value $Class;$item |add-member -type NoteProperty -Name 'Model' -Value $Model; $Assets_Table += $item}else{
for($x=0;$x -lt $Assets.Count;$x++){$item= New-Object PSObject;$item |add-member -type NoteProperty -Name 'SoftwareVersion' -Value $SoftwareVersion[$x] ;$item |add-member -type NoteProperty -Name 'AssetID' -Value $Assets[$x] ;$item |add-member -type NoteProperty -Name 'Hostname' -Value $Hostname[$x];$item | add-member -type NoteProperty -Name 'Function Unit' -Value $Function_Unit[$x];$item | add-member -type NoteProperty -Name 'Serial' -Value $Serial[$x];$item |add-member -type NoteProperty -Name 'Class' -Value $Class[$x];$item |add-member -type NoteProperty -Name 'Model' -Value $Model[$x]; $Assets_Table += $item}
}
return $Assets_Table

}

function Add-SpiderLocation {

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$RegionAdd,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$City,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Building,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Floor,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Room
        

)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")


$jsonBase = @{}
$listPara = @{'MandatorID'=0;"Country"="$Country";"Region"="$RegionAdd";"City"="$City";"Building"="$Building";"Floor"="$Floor";"Room"="$Room";"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SipderLocationUri="/0/entity/Location/"

Invoke-WebRequest -Uri "$spiderApiBaseUri$SipderLocationUri" -Headers $spiderHeader -Method Post -ContentType "application/json" -Body $SpiderRequestADD

}


function Add-SpiderSwitchFunctionUnit {

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Fu,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Name,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$IP_address,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$LocID,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$LegID,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$BU
        

)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")


$jsonBase = @{}
$listPara = @{'MandatorID'=0;'status'="Active";'identifier'="$Fu";"functionUnitStatusID"=14;"hostname"="$Name";"iP Address"="$IP_address";"locationid"=$LocID;"legalEntityID"=$LegID;"maintenance"="no";"business Unit"=$BU;"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchSystemUri = "/0/entity/Switch system/"

Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchSystemUri" -Headers $spiderHeader -Method Post -ContentType "application/json" -Body $SpiderRequestADD -TimeoutSec 120

}

function Add-SpiderSwitchAssetUnit {

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$AssetID,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Hostname,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Serial,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Class,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$modelName,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Function_Unit_ID
        

)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")


$jsonBase = @{}
$listPara = @{'MandatorID'=0;'assetStatusID' = 12;'functionUnitID'="$Function_Unit_ID";'hostName'="$Hostname";'serialNo'="$Serial";'modelName'=$modelName;'assetNo'=$AssetID;"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchAssetUri = "/0/entity/$($Class)/"

Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchAssetUri" -Headers $spiderHeader -Method Post -ContentType "application/json" -Body $SpiderRequestADD -TimeoutSec 120

}

function Add-SpiderSwitchAssetsChassisModel {

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Model
     
        

)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")


$jsonBase = @{}
$listPara = @{'MandatorID'=0;'Name' = $Model;"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchChassisModelUri = "/0/entity/Switch chassisTemplate/"

Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchChassisModelUri" -Headers $spiderHeader -Method Post -ContentType "application/json" -Body $SpiderRequestADD

}


function Add-SpiderSwitchAssetsModuleCardModel {

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Model
        

)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")


$jsonBase = @{}
$listPara = @{'MandatorID'=0;'Name' = $Model;"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchModuleCardModelUri = "/0/entity/Switch module cardTemplate/"

Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchModuleCardModelUri" -Headers $spiderHeader -Method Post -ContentType "application/json" -Body $SpiderRequestADD

}


function Add-SpiderSwitchAssetsPowerSupplyModel {

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Model
        

)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")


$jsonBase = @{}
$listPara = @{'MandatorID'=0;'Name' = $Model;"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchPowerSupplyModelUri = "/0/entity/Switch power supplyTemplate/"

Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchPowerSupplyModelUri" -Headers $spiderHeader -Method Post -ContentType "application/json" -Body $SpiderRequestADD

}

function Add-SpiderSwitchAssetsSSDModel {

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Model
        

)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")


$jsonBase = @{}
$listPara = @{'MandatorID'=0;'Name' = $Model;"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchSSDModelUri = "/0/entity/Switch SSDTemplate/"

Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchSSDModelUri" -Headers $spiderHeader -Method Post -ContentType "application/json" -Body $SpiderRequestADD

}

function Add-SpiderSwitchAssetsSecurityDeviceModel {

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Model
        

)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")


$jsonBase = @{}
$listPara = @{'MandatorID'=0;'Name' = $Model;"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchSecurityDeviceModelUri = "/0/entity/Security DeviceTemplate/"

Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchSecurityDeviceModelUri" -Headers $spiderHeader -Method Post -ContentType "application/json" -Body $SpiderRequestADD

}

function Sync-AssetsFromSpiderToSW {
Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$AssetNumberReg,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ReportNumber
        

)


$Assets = (Get-SpiderSwitches -spiderUser $spiderUser -spiderPass $spiderPass -Country $Country -spiderApiBaseUri $spiderApiBaseUri -ReportNumber $ReportNumber) | Select -exp 'asset number' | ? {$_ -like "$AssetNumberReg"}

Wait-Event -Timeout 5

$Serial = (Get-SpiderSwitches -spiderUser $spiderUser -spiderPass $spiderPass -Country $Country -spiderApiBaseUri $spiderApiBaseUri -ReportNumber $ReportNumber ) | ? {$_."asset number" -like "$AssetNumberReg"} |Select -exp 'serial number'

for($x=0;$x -lt $Assets.count;$x++){IF((Invoke-Sqlcmd -Query "Select AssetID from SolarWindsOrion.dbo.NCM_Entity_Physical WHERE Serial = '$($Serial[$x])' or HardwareRevision = '$($Serial[$x])'"  -Database $SQLDatabase -ServerInstance $SQLServerInstance -Username $SQLUsername -Password $SQLPassword)){Invoke-Sqlcmd -Query "UPDATE SolarWindsOrion.dbo.NCM_Entity_Physical SET AssetID = '$($Assets[$x])' WHERE ((Serial = '$($Serial[$x])' or HardwareRevision = '$($Serial[$x])')  and (Class = 'chassis(3)' or Class= 'module(9)' or Class= 'powerSupply(6)'))"  -Database $SQLDatabase -ServerInstance $SQLServerInstance -Username $SQLUsername -Password $SQLPassword}}


}

function Populate-SWDatabaseNewAssetsID {

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ReportNumber
        

)



$queryCurrentInfo = @"
Select n.Spider_Function_Unit, n.SysName, p.Model, p.Class, p.AssetID, p.Serial, p.HardwareRevision, n.SysLocation, n.Department, n.AgentIP, n.Region, n.Business_Unit, n.LTN, n.Maintenance from SolarWindsOrion.dbo.NCM_Nodes as n

Left join SolarWindsOrion.dbo.NCM_Entity_Physical as p on n.NodeID = p.NodeID
where  n.country = '$Country' and n.Carrier_Name is NULL  and (p.Class = 'module(9)' or p.Class = 'chassis(3)' or p.Class = 'powersupply(6)') and not p.Serial = '' and not p.Model = '' 
"@

$SQLSWList = Invoke-Sqlcmd -query $queryCurrentInfo -Database $SQLDatabase -ServerInstance $SQLServerInstance -Username $SQLUsername -Password $SQLPassword

$AssetsIDSerialtoADD = $SQLSWList | Select AssetID, Serial | ? {$_.AssetID -like ""} | Select -exp serial


IF($AssetsIDSerialtoADD){

Write-log -Message "New Asset Units ID should be applied." -Country $Country -Severity Warning

Foreach($SerialAsset in $AssetsIDSerialtoADD){


$queryLastID = @"
Select Last_Spider_Asset_Unit, C.ContainerID from SolarWindsOrion.dbo.Containers as P
left join SolarWindsOrion.dbo.ContainerCustomProperties as C on C.ContainerID = P.ContainerID
where P.Name = '$($Country)'
"@

$LastAssetID =  Invoke-Sqlcmd -query $queryLastID -Database $SQLDatabase -ServerInstance $SQLServerInstance -Username $SQLUsername -Password $SQLPassword
if(!$LastAssetID){
$LastAssetID = (Get-SpiderSwitches -spiderUser $spiderUser -spiderPass $spiderPass -Country $Country -spiderApiBaseUri $spiderApiBaseUri -ReportNumber $ReportNumber  | ? {$_."asset number" -like "*SW*"})."asset number" |sort -Descending | Select -First 1
}

$NextAsset = ($LastAssetID.Last_Spider_Asset_Unit -replace "[0-9]*") + [string]([int]($LastAssetID.Last_Spider_Asset_Unit -replace "^[a-z]*") + 1)
$queryUpdate = @"
UPDATE SolarWindsOrion.dbo.NCM_Entity_Physical SET AssetID = '$($NextAsset)' WHERE Serial = '$($SerialAsset)' or HardwareRevision = '$($SerialAsset)' 

UPDATE SolarWindsOrion.dbo.ContainerCustomProperties SET Last_Spider_Asset_Unit = '$($NextAsset)' WHERE ContainerID = '$($LastAssetID.ContainerID)'

"@

Invoke-Sqlcmd -query $queryUpdate -Database $SQLDatabase -ServerInstance $SQLServerInstance -Username $SQLUsername -Password $SQLPassword
Wait-Event -Timeout 5

}
}else{Write-log -Message "Nothing to add to Asset Unit." -Country $Country -Severity Information}


}

function Populate-SWDatabaseNewFunctionUnitID {

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ReportNumber        

)


$queryCurrentInfo = @"
Select n.Spider_Function_Unit, n.SysName, p.Model, p.Class, p.AssetID, p.Serial, p.HardwareRevision, n.SysLocation, n.Department, n.AgentIP, n.LTN, n.Region, n.Business_Unit, n.Maintenance from SolarWindsOrion.dbo.NCM_Nodes as n

Left join SolarWindsOrion.dbo.NCM_Entity_Physical as p on n.NodeID = p.NodeID
where  n.country = '$Country' and n.Carrier_Name is NULL  and (p.Class = 'module(9)' or p.Class = 'chassis(3)' or p.Class = 'powersupply(6)') and not p.Serial = '' and not p.Model = '' 
"@

$SQLSWList = Invoke-Sqlcmd -query $queryCurrentInfo -Database $SQLDatabase -ServerInstance $SQLServerInstance -Username $SQLUsername -Password $SQLPassword

$FunctionUnitIDNametoADD = ($SQLSWList | Select Spider_Function_Unit, Sysname | ? {$_.Spider_Function_Unit -like ""} | Select -exp Sysname | Select -Unique) -replace "\.[a-z]*",""


IF($FunctionUnitIDNametoADD){
Write-log -Message "New Function Units ID should be applied." -Country $Country -Severity Warning

Foreach($NameFU in $FunctionUnitIDNametoADD){


$queryLastID = @"
Select Max_Spider_Function_Unit, Last_Spider_Function_Unit, C.ContainerID from SolarWindsOrion.dbo.Containers as P
left join SolarWindsOrion.dbo.ContainerCustomProperties as C on C.ContainerID = P.ContainerID
where P.Name = '$($Country)'
"@

$LastFUID =  Invoke-Sqlcmd -query $queryLastID -Database $SQLDatabase -ServerInstance $SQLServerInstance -Username $SQLUsername -Password $SQLPassword



if(!$LastFUID){
$LastFUID = (Get-SpiderSwitches -spiderUser $spiderUser -spiderPass $spiderPass -Country $Country -spiderApiBaseUri $spiderApiBaseUri -ReportNumber $ReportNumber)."identifier" |sort -Descending | Select -First 1
}

IF($LastFUID.Last_Spider_Function_Unit[2] -notlike "0"){

$NextFU = ($LastFUID.Last_Spider_Function_Unit -replace "[0-9]*") +[string]([int]($LastFUID.Last_Spider_Function_Unit -replace "^[a-z]*") + 1)
}else{

$NextFU = ($LastFUID.Last_Spider_Function_Unit -replace "[0-9]*") + $LastFUID.Last_Spider_Function_Unit[2]+[string]([int]($LastFUID.Last_Spider_Function_Unit -replace "^[a-z]*") + 1)
}

IF($NextFU -lt $LastFUID.Max_Spider_Function_Unit){

$queryUpdate = @"
UPDATE SolarWindsOrion.dbo.Nodes SET Spider_Function_Unit = '$($NextFU)' WHERE Caption like '$($NameFU)%' 

UPDATE SolarWindsOrion.dbo.ContainerCustomProperties SET Last_Spider_Function_Unit = '$($NextFU)' WHERE ContainerID = '$($LastFUID.ContainerID)'

"@

Invoke-Sqlcmd -query $queryUpdate -Database $SQLDatabase -ServerInstance $SQLServerInstance -Username $SQLUsername -Password $SQLPassword 
Wait-Event -Timeout 5


}else{Write-log -Message "$NextFU exceeded maximum value for country $LastFUID.Max_Spider_Function_Unit.Need new range" -Country $Country -Severity Error}
}


}else{Write-log -Message "Nothing to add to Function Unit." -Country $Country -Severity Information}
}

function Populate-SpiderLocations {

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword

        )

$FU_Table = Get-FunctionUnitFromattedList  -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country
$SpiderLocList = Get-SwitchesLocations -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -Country $Country
$SpiderLocationsListToAdd = diff ($SpiderLocList | Select -exp path) ($FU_Table |? {$_."Function Unit" -notlike ''}| Select -exp Location | Select -Unique) | ? {$_.SideIndicator -like "=>"} | Select -exp InputObject | Select -Unique

IF($SpiderLocationsListToAdd){
Write-log -Message "Spider Location Units needs to be uploaded to extend existing Spider DB" -Severity Warning -Country $Country
Foreach($LocPath in $SpiderLocationsListToAdd){

$Country = $LocPath -replace "\/.*",""
$Room =  $LocPath -replace ".*\/",""
$City = $LocPath -replace "^[a-z\s]*\/|\/.*$",""
$Building = ($LocPath -replace "^[a-z\s]*\/[a-z,.'\#\)\(\-\s\d]*\/","") -replace "\/[a-z.,\-\s0-9]*\/[a-z,.'\#\)\(\-\d\s]*$"
$Floor = (($LocPath -replace "^[a-z\s]*\/[a-z,.'\#\)\(\-\s\d]*\/","") -replace "\s\/\s", "") -replace "^[a-z,.&'`"\#\)\(\-\d\s]*\/|\/[a-z,.'\#\)\(\-\d\s]*$"


If($Country -like "Czech"){$CountrySW = "Czech Republic"}
elseif($Country -like "United Arab Emirates"){$CountrySW = "UAE"}
else{$CountrySW = $Country}

$queryRegioncheck = @"
Select C.Name from SolarWindsOrion.dbo.Containers as N
left join SolarWindsOrion.dbo.ContainerMemberSnapshots as M on N.ContainerID  = M.EntityID and M.EntityType='Orion.Groups'
LEFT JOIN SolarwindsOrion.dbo.Containers AS C ON C.ContainerID=M.ContainerID 

where M.Name = '$($CountrySW)'

"@

$RegionADD = (Invoke-Sqlcmd -Query $queryRegioncheck -Database $SQLDatabase -ServerInstance $SQLServerInstance -Username $SQLUsername -Password $SQLPassword).Name

if($Building.Length -lt 50){
$Results = $null

$Results = Add-SpiderLocation -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -Country $Country -RegionAdd $RegionADD -City $City -Room $Room -Floor $Floor -Building $Building
IF(($Results.StatusCode -like "200") -and (($Results.Content | ConvertFrom-Json).id -notlike "")){Write-log -Message "$(($Results.Content | ConvertFrom-Json).id)  $RegionADD/$Country/$City/$Building/$Floor/$Room  was successfully added" -Country $Country -Severity Information}else{
Write-log -Message "$RegionADD/$Country/$City/$Building/$Floor/$Room was not added succeeded" -Country $Country -Severity Error
}


Wait-Event -Timeout 5
}else{Write-log -Message "$RegionADD/$Country/$City/$Building/$Floor/$Room was not added succeeded - Buildint/Street name has more than 50 chars" -Country $Country -Severity Error}

}
}else{Write-log -Message "Spider Locations Units at Spider DB are fully consistent" -Severity Information -Country $Country}

}

function Populate-FunctionUnits {

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ReportNumber        

)

$FU_table = Get-FunctionUnitFromattedList -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -Country $Country -SQLUsername $SQLUsername -SQLPassword $SQLPassword


Wait-Event -Timeout 5
$SpiderLegalList = Get-SwitchesLegalEntity  -spiderUser $spiderUser -spiderPass $spiderPass -Country $Country -spiderApiBaseUri $spiderApiBaseUri

Wait-Event -Timeout 5
$SpiderLocList  = Get-SwitchesLocations -spiderUser $spiderUser -spiderPass $spiderPass -Country $Country -spiderApiBaseUri $spiderApiBaseUri 

Wait-Event -Timeout 5
$SpiderFunctionUnitList = Get-SpiderSwitches -spiderUser $spiderUser -spiderPass $spiderPass -Country $Country -spiderApiBaseUri $spiderApiBaseUri -ReportNumber $ReportNumber
Wait-Event -Timeout 5

IF($SpiderFunctionUnitList){
$SpiderFunctionUnitListtoAdd= diff ($SpiderFunctionUnitList | Select -exp identifier -ErrorAction Continue) ($FU_Table |? {$_."Function Unit" -notlike ''}| Select -exp "Function Unit" | Select -Unique) | ? {$_.SideIndicator -like "=>"} | Select -exp InputObject | Select -Unique
If($SpiderFunctionUnitListtoAdd){
Write-log -Message "Spider Function Units needs to be uploaded to extend existing Spider DB" -Severity Warning -Country $Country
Foreach($FU in $SpiderFunctionUnitListtoAdd){
$FUADD = $FU_Table  |? {$_."Function Unit" -like $FU} |? {$_."Function Unit" -notlike ''}| Select -exp 'Function Unit'
$NameAdd = $FU_Table | ? {$_."Function Unit" -like $FU} | Select -exp Name
$LocationIDAdd = ($SpiderLocList | ? {$_.path -like ($FU_Table | ? {$_."Function Unit" -like $FU} | Select -exp 'Location')} | Select -exp id)
$LegalEntityIDAdd = ($SpiderLegalList | ? {$_.path -like (($FU_Table | ? {$_."Function Unit" -like $FU} | Select -exp 'Legal Entity'))} | Select -exp id)
$IPADD = $FU_Table | ? {$_."Function Unit" -like $FU} | Select -exp IP
$BUADD = $FU_Table | ? {$_."Function Unit" -like $FU} | Select -exp 'Business Unit'

$Results = $null

$Results = Add-SpiderSwitchFunctionUnit -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -Fu $FUADD -Name $NameADD -IP_address $IPADD -LocID $LocationIDAdd -LegID $LegalEntityIDAdd -BU $BUADD 
IF(($Results.StatusCode -like "200") -and (($Results.Content | ConvertFrom-Json).id -notlike "")){Write-log -Message "$(($Results.Content | ConvertFrom-Json).id)  $FUADD  $NameADD $IPADD  was successfully added" -Country $Country -Severity Information}else{
Write-log -Message "$FUADD $NameADD  $IPADD was not added succeeded" -Country $Country -Severity Error
}

Wait-Event -Timeout 5

}
}else{Write-log -Message "Spider Switch Function Units at Spider DB are fully consistent" -Severity Information -Country $Country}

}else
{
Write-log -Message "Spider Function Units absent at Spider DB, strating population from scratch" -Severity Warning -Country $Country
Foreach($FU in $FU_Table){
$FUADD = $FU.'Function Unit'
$NameAdd = $FU.Name
$LocationIDAdd = ($SpiderLocList | ? {$_.path -like $FU.Location} | Select -exp id)
$LegalEntityIDAdd = ($SpiderLegalList | ? {$_.path -like $FU."Legal Entity"} | Select -exp id)
$IPADD = $FU.IP
$MaintenanceAdd = $FU.Maintenance
$BUADD = $FU.'Business Unit'

$Results = $null

$Results = Add-SpiderSwitchFunctionUnit -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri  $spiderApiBaseUri -Fu $FUADD -Name $NameADD -IP_address $IPADD -LocID $LocationIDAdd -LegID $LegalEntityIDAdd -BU $BUADD 
IF(($Results.StatusCode -like "200") -and (($Results.Content | ConvertFrom-Json).id -notlike "")){Write-log -Message "$(($Results.Content | ConvertFrom-Json).id)  $FUADD  $NameADD $IPADD  was successfully added" -Country $Country -Severity Information}else{
Write-log -Message "$FUADD $NameADD  $IPADD was not added succeeded" -Country $Country -Severity Error
}


Wait-Event -Timeout 5

}

}
}

function Populate-AssetUnits{

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$AssetNumberReg,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ReportNumber        

)

$Assets_Table = Get-AssetUnitFromattedList  -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country 
Wait-Event -Timeout 5
$SpiderFunctionUnitList = Get-SpiderSwitches -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -Country $Country  -ReportNumber $ReportNumber
Wait-Event -Timeout 5
if($SpiderFunctionUnitList."asset number" | ? {$_ -like "$AssetNumberReg"}){

$SpiderAssetUnitsListToADD = diff ($SpiderFunctionUnitList."asset number" | ? {$_ -like "$AssetNumberReg"})  $Assets_Table.AssetID | ? {$_.SideIndicator -like "=>"} | Select -exp InputObject | ? {$_ -notlike ""} 

if($SpiderAssetUnitsListToADD){
Write-log -Message "Spider Asset Units needs to be uploaded to extend existing Spider DB" -Severity Warning -Country $Country

Foreach ($Asset in $SpiderAssetUnitsListToADD){

$HostnameADD = $Assets_Table | ? {$_.AssetID -like $Asset} | Select -exp Hostname
$AssetIDADD = $Assets_Table | ? {$_.AssetID -like $Asset} | Select -exp AssetID
$FUIDADD = $SpiderFunctionUnitList | ? {$_.identifier -like ($Assets_Table | ? {$_.AssetID -like $Asset} | Select -exp "Function Unit")} | Select -exp id | Select -Unique
$SerialADD = $Assets_Table | ? {$_.AssetID -like $Asset} | Select -exp Serial
$ModelADD = $Assets_Table | ? {$_.AssetID -like $Asset} | Select -exp Model
$ClassADD = $Assets_Table | ? {$_.AssetID -like $Asset} | Select -exp Class

$Results = $null

$Results = Add-SpiderSwitchAssetUnit -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -AssetID $AssetIDADD -Hostname $HostnameADD -Function_Unit_ID $FUIDADD -Serial $SerialADD -Class $ClassADD -modelName $ModelADD
IF(($Results.StatusCode -like "200") -and (($Results.Content | ConvertFrom-Json).id -notlike "")){Write-log -Message "$(($Results.Content | ConvertFrom-Json).id)   $AssetIDADD  $HostnameADD $FUIDADD $SerialADD $ClassADD $ModelADD   was successfully added" -Country $Country -Severity Information}else{
Write-log -Message "$AssetIDADD  $HostnameADD $FUIDADD $SerialADD $ClassADD $ModelADD was not added succeeded" -Country $Country -Severity Error
}

Wait-Event -Timeout 5

}
}else{Write-log -Message "Spider Switch Asset Units at Spider DB are fully consistent" -Severity Information -Country $Country}
}
else
{
Write-log -Message "Spider Asset Units absent at Spider DB, strating population from scratch" -Severity Warning -Country $Country
Foreach ($Asset in $Assets_Table){

$HostnameADD = $Asset.Hostname
$AssetIDADD = $Asset.AssetID
$FUIDADD = $SpiderFunctionUnitList | ? {$_.identifier -like $Asset."Function Unit"} | Select -exp id
$SerialADD = $Asset.Serial
$ModelADD = $Asset.Model
$ClassADD = $Asset.Class

$Results = $null

$Results = Add-SpiderSwitchAssetUnit -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -AssetID $AssetIDADD -Hostname $HostnameADD -Function_Unit_ID $FUIDADD -Serial $SerialADD -Class $ClassADD -modelName $ModelADD
IF(($Results.StatusCode -like "200") -and (($Results.Content | ConvertFrom-Json).id -notlike "")){Write-log -Message "$(($Results.Content | ConvertFrom-Json).id)   $AssetIDADD  $HostnameADD $FUIDADD $SerialADD $ClassADD $ModelADD   was successfully added" -Country $Country -Severity Information}else{
Write-log -Message "$AssetIDADD  $HostnameADD $FUIDADD $SerialADD $ClassADD $ModelADD was not added succeeded" -Country $Country -Severity Error
}

Wait-Event -Timeout 5

}


}

}

function Populate-SpiderAssetsModelSWChassis {

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword
        

)

$Assets_Table = Get-AssetUnitFromattedList  -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country

$SpiderAssetsSwitchChassisModelList = Get-SwitchesAssetsChassisModel -spiderUser $spiderUser -spiderPass $spiderPass  -spiderApiBaseUri $spiderApiBaseUri

$AssetsChassisModelSW = $Assets_Table | ? {$_.Class -like "Switch chassis"} | Select -exp Model | Select -Unique

try{$AssetsChassisModeltoADD = diff ($SpiderAssetsSwitchChassisModelList.Name| ? {$_ -notlike ""}) $AssetsChassisModelSW | ? {$_.SideIndicator -like "=>"} | Select -exp InputObject}catch{}

IF($AssetsChassisModeltoADD){
Write-log -Message "Spider Assets Model Switch Chassis Units needs to be uploaded to extend existing Spider DB" -Severity Warning -Country $Country
Foreach($Model in $AssetsChassisModeltoADD){

$Results = $null

$Results = Add-SpiderSwitchAssetsChassisModel -spiderUser $spiderUser -spiderPass $spiderPass  -spiderApiBaseUri $spiderApiBaseUri -Model $Model

IF(($Results.StatusCode -like "200") -and (($Results.Content | ConvertFrom-Json).id -notlike "")){Write-log -Message "$(($Results.Content | ConvertFrom-Json).id)  $Model was successfully added" -Country $Country -Severity Information}else{
Write-log -Message "$Model was not added succeeded" -Country $Country -Severity Error
}

Wait-Event -Timeout 5
}
}else{Write-log -Message "Spider Assets Model Switch Chassis Units at Spider DB are fully consistent" -Severity Information -Country $Country}

}

function Populate-SpiderAssetsModelSWModuleCard {

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword
        

)

$Assets_Table = Get-AssetUnitFromattedList  -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country

$SpiderAssetsModuleCartModelList = Get-SwitchesAssetsModuleCardModel -spiderUser $spiderUser -spiderPass $spiderPass  -spiderApiBaseUri $spiderApiBaseUri

$AssetsModuleCardModelSW = $Assets_Table | ? {$_.Class -like "Switch module card"} | Select -exp Model | Select -Unique

try{$AssetsModuleCardModeltoADD = diff ($SpiderAssetsModuleCartModelList.Name | ? {$_ -notlike ""}) $AssetsModuleCardModelSW | ? {$_.SideIndicator -like "=>"} | Select -exp InputObject}catch{}

IF($AssetsModuleCardModeltoADD){
Write-log -Message "Spider Assets Model Switch Module Card Units needs to be uploaded to extend existing Spider DB" -Severity Warning -Country $Country

Foreach($Model in $AssetsModuleCardModeltoADD){

$Results = $null

$Results =Add-SpiderSwitchAssetsModuleCardModel -spiderUser $spiderUser -spiderPass $spiderPass  -spiderApiBaseUri $spiderApiBaseUri -Model $Model
IF(($Results.StatusCode -like "200") -and (($Results.Content | ConvertFrom-Json).id -notlike "")){Write-log -Message "$(($Results.Content | ConvertFrom-Json).id)  $Model was successfully added" -Country $Country -Severity Information}else{
Write-log -Message "$Model was not added succeeded" -Country $Country -Severity Error
}


Wait-Event -Timeout 5

}
}else{Write-log -Message "Spider Assets Model Switch Module Card Units at Spider DB are fully consistent" -Severity Information -Country $Country}

}

function Populate-SpiderAssetsModelSWPowerSupply{

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword
        

)

$Assets_Table = Get-AssetUnitFromattedList  -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country

$SpiderAssetsPowerSupplyModelList = Get-SwitchesAssetsPowerSupplyModel -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri

$AssetsPowerSupplyModelSW = $Assets_Table | ? {$_.Class -like "Switch power supply"} | Select -exp Model | Select -Unique

try{$AssetsPowerSupplyModeltoADD = diff $SpiderAssetsPowerSupplyModelList.Name $AssetsPowerSupplyModelSW | ? {$_.SideIndicator -like "=>"} | Select -exp InputObject}catch{}

IF($AssetsPowerSupplyModeltoADD){
Write-log -Message "Spider Assets Model Switch Power Supply Units needs to be uploaded to extend existing Spider DB" -Severity Warning -Country $Country

Foreach($Model in $AssetsPowerSupplyModeltoADD){

$Results = $null

$Results=Add-SpiderSwitchAssetsPowerSupplyModel -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -Model $Model

IF(($Results.StatusCode -like "200") -and (($Results.Content | ConvertFrom-Json).id -notlike "")){Write-log -Message "$(($Results.Content | ConvertFrom-Json).id)  $Model was successfully added" -Country $Country -Severity Information}else{
Write-log -Message "$Model was not added succeeded" -Country $Country -Severity Error
}

Wait-Event -Timeout 5

}
}else{Write-log -Message "Spider Assets Model Power Supply Units at Spider DB are fully consistent" -Severity Information -Country $Country}

}

function Populate-SpiderAssetsModelSWSSD{

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword
        

)

$Assets_Table = Get-AssetUnitFromattedList  -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country

$SpiderAssetsSSDModelList = Get-SwitchesAssetsSSDModel -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri

$AssetsSSDModelSW =  $Assets_Table | ? {$_.Class -like "Switch SSD"} | Select -exp Model | Select -Unique

try{$AssetsSSDModeltoADD = diff $SpiderAssetsSSDModelList.Name $AssetsSSDModelSW | ? {$_.SideIndicator -like "=>"} | Select -exp InputObject}catch{}

IF($AssetsSSDModeltoADD){
Write-log -Message "Spider Assets Model Switch SSD Units needs to be uploaded to extend existing Spider DB" -Severity Warning -Country $Country

Foreach($Model in $AssetsSSDModeltoADD){


$Results = $null

$Results = Add-SpiderSwitchAssetsSSDModel -spiderUser  $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -Model $Model

IF(($Results.StatusCode -like "200") -and (($Results.Content | ConvertFrom-Json).id -notlike "")){Write-log -Message "$(($Results.Content | ConvertFrom-Json).id)  $Model was successfully added" -Country $Country -Severity Information}else{
Write-log -Message "$Model was not added succeeded" -Country $Country -Severity Error
}

Wait-Event -Timeout 5

}
}else{Write-log -Message "Spider Assets Model Switch SSD Units at Spider DB are fully consistent" -Severity Information -Country $Country}

}

function Populate-SpiderAssetsModelSecurityDevice{

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword

        

)

$Assets_Table = Get-AssetUnitFromattedList  -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country 
Wait-Event -Timeout 5
$SpiderAssetsSecurityDeviceModelList = Get-SwitchesAssetsSecurityDeviceModel -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri 
Wait-Event -Timeout 5
$AssetsSecurityDeviceModelSW = $Assets_Table | ? {$_.Class -like "Security Device"} | Select -exp Model | Select -Unique

try{$AssetsSecurityDeviceModeltoADD = diff $SpiderAssetsSecurityDeviceModelList.Name $AssetsSecurityDeviceModelSW | ? {$_.SideIndicator -like "=>"} | Select -exp InputObject}catch{}

IF($AssetsSecurityDeviceModeltoADD){
Write-log -Message "Spider Assets Model Security Device Units needs to be uploaded to extend existing Spider DB" -Severity Warning -Country $Country

Foreach($Model in $AssetsSecurityDeviceModeltoADD){

$Results = $null

$Results=Add-SpiderSwitchAssetsSecurityDeviceModel -spiderUser $spiderUser -spiderPass $SQLPassword -spiderApiBaseUri $spiderApiBaseUri -Model $Model

IF(($Results.StatusCode -like "200") -and (($Results.Content | ConvertFrom-Json).id -notlike "")){Write-log -Message "$(($Results.Content | ConvertFrom-Json).id)  $Model was successfully added" -Country $Country -Severity Information}else{
Write-log -Message "$Model was not added succeeded" -Country $Country -Severity Error
}


Wait-Event -Timeout 5

}
}else{Write-log -Message "Spider Assets Model Security Device Units at Spider DB are fully consistent" -Severity Information -Country $Country}

}

function Update-FunctionUnitsLocations{

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$AssetNumberReg,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ReportNumber
        

)





$SpiderLocList = Get-SwitchesLocations -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -Country $Country

$FU_table = Get-FunctionUnitFromattedList -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -Country $Country -SQLUsername $SQLUsername -SQLPassword $SQLPassword

$SpiderFunctionUnitList = Get-SpiderSwitches -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -Country $Country  -ReportNumber $ReportNumber

$CurrentFu = ($SpiderFunctionUnitList | ? {$_."asset number" -like "$AssetNumberReg"}) | Select -exp identifier | Select -Unique

Foreach($FU in $CurrentFu){
try{
$SpiderFunctionUnitLocationtoUpdate = diff ($FU_table | ? {$_."function unit" -like $FU} | Select -exp location) ($SpiderFunctionUnitList | ? {$_."identifier" -like $FU} | Select -exp location | Select -Unique) | ? {$_.SideIndicator -like "<="} | Select -ExpandProperty InputObject
}catch{}

IF($SpiderFunctionUnitLocationtoUpdate){


$EntityID = $SpiderFunctionUnitList | ? {$_."identifier" -like $FU} | Select -exp id | Select -Unique
$LocID =  $SpiderLocList | ? {$_.path -like $SpiderFunctionUnitLocationtoUpdate} | Select -exp id

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")



$jsonBase = @{}
$listPara = @{"locationid"=$LocID;"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchSystemUri = "/0/entity/Switch system/$EntityID"

$Results = $null

$Results = Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchSystemUri" -Headers $spiderHeader -Method PUT -ContentType "application/json" -Body $SpiderRequestADD
IF(($Results.StatusCode -like "200")){Write-log -Message "$EntityID $FU was updated successfully to $SpiderFunctionUnitLocationtoUpdate" -Country $Country -Severity Information}else{
Write-log -Message "$EntityID $FU location was not updated succeeded to $SpiderFunctionUnitLocationtoUpdate" -Country $Country -Severity Error
}

Wait-Event -Timeout 5


}



}

}

function Update-AssetUnitsFunctionUnitID{

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$AssetNumberReg,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ReportNumber
        

)

$Assets_Table = Get-AssetUnitFromattedList  -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country

$SpiderFunctionUnitList = Get-SpiderSwitches -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -Country $Country  -ReportNumber $ReportNumber

$CurrentAssets = ($SpiderFunctionUnitList | ? {$_."asset number" -like "$AssetNumberReg"}) | Select -exp "asset number"

Foreach($Asset in $CurrentAssets){

try{
$SpiderAssetUnitFunctionUnitIDtoUpdate = diff ($Assets_table | ? {$_.AssetID -like $Asset} | Select -exp "Function Unit") ($SpiderFunctionUnitList | ? {$_."asset number" -like $Asset} | Select -exp identifier | Select -Unique) | ? {$_.SideIndicator -like "<="} | Select -ExpandProperty InputObject
}catch{}

IF($SpiderAssetUnitFunctionUnitIDtoUpdate){

IF(($SpiderFunctionUnitList | ? {$_."asset number" -like $Asset} | Select -exp "asset status" ) -notlike "active"){

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")



$jsonBase = @{}
$listPara = @{'assetStatusID' = 12;"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchSystemUri = "/0/entity/$($Assets_Table | ? {$_.assetid -like $Asset}|Select -exp Class)/$EntityID"

$Results = $null

$Results = Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchSystemUri" -Headers $spiderHeader -Method PUT -ContentType "application/json" -Body $SpiderRequestADD
IF(($Results.StatusCode -like "200")){Write-log -Message "$EntityID $Asset Function unit ID was updated successfully to $SpiderAssetUnitFunctionUnitIDtoUpdate" -Country $Country -Severity Information}else{
Write-log -Message "$EntityID $Asset Function unit ID was not updated succeeded to $SpiderAssetUnitFunctionUnitIDtoUpdate" -Country $Country -Severity Error
}

Wait-Event -Timeout 5

}

$EntityID = $SpiderFunctionUnitList | ? {$_."asset number" -like $Asset} | Select -exp assetid | Select -Unique
$FUID = $SpiderFunctionUnitList | ? {$_."identifier" -like $SpiderAssetUnitFunctionUnitIDtoUpdate} | Select -exp id -Unique
$NewHostname = $SpiderFunctionUnitList | ? {$_."identifier" -like $SpiderAssetUnitFunctionUnitIDtoUpdate} | Select -exp name -Unique

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")



$jsonBase = @{}
$listPara = @{"functionUnitID"=$FUID;"hostName"=$NewHostname;"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchSystemUri = "/0/entity/$($Assets_Table | ? {$_.assetid -like $Asset}|Select -exp Class)/$EntityID"

$Results = $null

$Results = Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchSystemUri" -Headers $spiderHeader -Method PUT -ContentType "application/json" -Body $SpiderRequestADD
IF(($Results.StatusCode -like "200")){Write-log -Message "$EntityID $Asset Function unit ID was updated successfully to $SpiderAssetUnitFunctionUnitIDtoUpdate" -Country $Country -Severity Information}else{
Write-log -Message "$EntityID $Asset Function unit ID was not updated succeeded to $SpiderAssetUnitFunctionUnitIDtoUpdate" -Country $Country -Severity Error
}

Wait-Event -Timeout 5

}else{}
}

}

function Update-AssetUnitsSoftwareVersion{

Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$AssetNumberReg,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ReportNumber        

)

$Assets_Table = Get-AssetUnitFromattedList  -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country

$SpiderFunctionUnitList = Get-SpiderSwitches -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -Country $Country  -ReportNumber $ReportNumber

$CurrentAssets = ($SpiderFunctionUnitList | ? {$_."asset number" -like "$AssetNumberReg"}) | Select -exp 'asset number'


Foreach($Asset in $CurrentAssets){

try{
$SpiderAssetUnitSoftWareVersiontoUpdate = diff ($Assets_table | ? {$_.AssetID -like $Asset} | Select -exp "SoftwareVersion") ($SpiderFunctionUnitList | ? {$_."asset number" -like $Asset} | Select -exp 'software Version') | ? {$_.SideIndicator -like "<="} | Select -ExpandProperty InputObject
}catch{}

IF($SpiderAssetUnitSoftWareVersiontoUpdate){

Write-log -Message "$Asset should be update with new Software Version $SpiderAssetUnitSoftWareVersiontoUpdate" -Country $Country -Severity Warning

$EntityID = $SpiderFunctionUnitList | ? {$_."asset number" -like $Asset} | Select -exp assetid | Select -Unique
$SoftwareVersion = $Assets_table | ? {$_.AssetID -like $Asset}  | Select -exp SoftwareVersion


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")



$jsonBase = @{}
$listPara = @{"software version"=$SoftwareVersion;"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchSystemUri = "/0/entity/$($Assets_Table | ? {$_.assetid -like $Asset}|Select -exp Class)/$EntityID"

$Results = $null

$Results = Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchSystemUri" -Headers $spiderHeader -Method PUT -ContentType "application/json" -Body $SpiderRequestADD
IF(($Results.StatusCode -like "200")){Write-log -Message "$EntityID $Asset Software Version  was updated successfully to $SpiderAssetUnitSoftWareVersiontoUpdate" -Country $Country -Severity Information}else{
Write-log -Message "$EntityID $Asset Software Version was not updated succeeded to $SoftwareVersion" -Country $Country -Severity Error 
}

Wait-Event -Timeout 5



}else{
if(!($SpiderFunctionUnitList | ? {$_."asset number" -like $Asset} | Select -exp 'software Version') -and ($Assets_table | ? {$_.AssetID -like $Asset}  | Select -exp SoftwareVersion)){
Write-log -Message "$Asset at spider is Emtpy. Will be updated with $($Assets_table | ? {$_.AssetID -like $Asset}  | Select -exp SoftwareVersion) from SW" -Country $Country -Severity Warning


$EntityID = $SpiderFunctionUnitList | ? {$_."asset number" -like $Asset} | Select -exp assetid | Select -Unique
$SoftwareVersion = $Assets_table | ? {$_.AssetID -like $Asset}  | Select -exp SoftwareVersion

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")



$jsonBase = @{}
$listPara = @{"software version"=$SoftwareVersion;"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchSystemUri = "/0/entity/$($Assets_Table | ? {$_.assetid -like $Asset}|Select -exp Class)/$EntityID"

$Results = $null

$Results = Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchSystemUri" -Headers $spiderHeader -Method PUT -ContentType "application/json" -Body $SpiderRequestADD
IF(($Results.StatusCode -like "200")){Write-log -Message "$EntityID $Asset Software Version was updated successfully to $SoftwareVersion" -Country $Country -Severity Information}else{
Write-log -Message "$EntityID $Asset Software Version was not updated succeeded to $SoftwareVersion" -Country $Country -Severity Error
}

Wait-Event -Timeout 5




}else{}

}
}

}

function Update-UnitsStatus{
Param ( 
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderUser,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderPass,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$spiderApiBaseUri,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLDatabase,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLServerInstance,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLUsername,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$SQLPassword,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$AssetNumberReg,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$ReportNumber
        

)

$Assets_Table = Get-AssetUnitFromattedList  -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country

Wait-Event -Timeout 5

$FU_table = Get-FunctionUnitFromattedList -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -Country $Country -SQLUsername $SQLUsername -SQLPassword $SQLPassword

Wait-Event -Timeout 5

$SpiderFunctionUnitList = Get-SpiderSwitches -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -Country $Country -ReportNumber $ReportNumber  

Wait-Event -Timeout 5

$CurrentFu = ($SpiderFunctionUnitList | ? {$_."name" -notlike "Old_*"}| ? {$_."asset number" -like "$AssetNumberReg"}) | Select -exp identifier | Select -Unique

$FunctionUnittoDispose = diff $CurrentFU $FU_table."Function Unit" | ? {$_.SideIndicator -like "<="} | Select -exp InputObject

if($FunctionUnittoDispose){

Write-log -Message "Old not in use device's Function Units detected.Need to disable in Spider" -Country $Country -Severity Warning

Foreach($FU in $FunctionUnittoDispose){

$EntityID = $SpiderFunctionUnitList | ? {$_."identifier" -like $FU} | Select -exp id | Select -Unique


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")



$jsonBase = @{}
$listPara = @{"functionUnitStatusID"=15;"hostName"="Old_$($SpiderFunctionUnitList | ? {$_."identifier" -like $FU} | Select -exp name | Select -Unique)";"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchSystemUri = "/0/entity/Switch system/$EntityID"

$Results = $null

$Results = Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchSystemUri" -Headers $spiderHeader -Method PUT -ContentType "application/json" -Body $SpiderRequestADD
IF(($Results.StatusCode -like "200")){Write-log -Message "$EntityID $FU was successfully disabled" -Country $Country -Severity Information}else{
Write-log -Message "$EntityID $FU  was not disabled." -Country $Country -Severity Error
}

Wait-Event -Timeout 5


}
}else{Write-log -Message "No outdated Function Units info were found." -Country $Country -Severity Information}

 
$CurrentAssets = ($SpiderFunctionUnitList | ? {$_."asset Status" -like "active"} |? {$_."asset number" -like "$AssetNumberReg"})  | Select -exp "asset number"

$AssetstoDispose = diff $CurrentAssets $Assets_Table.assetid | ? {$_.SideIndicator -like "<="} | Select -exp InputObject

if($AssetstoDispose){
Write-log -Message "Old not in use device's Asset Units detected.Need to disable in Spider" -Country $Country -Severity Warning

Foreach($Asset in $AssetstoDispose){


$EntityID = $SpiderFunctionUnitList | ? {$_."asset number" -like $Asset} | Select -exp assetid | Select -Unique


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")



$jsonBase = @{}
$listPara = @{"assetStatusID"=39;"hostName"="Old_$($SpiderFunctionUnitList | ? {$_."asset number" -like $Asset} | Select -exp name | Select -Unique)";"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchSystemUri = "/0/entity/$($SpiderFunctionUnitList | ? {$_."asset number" -like $Asset}|Select -exp "asset Type")/$EntityID"

$Results = $null

$Results = Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchSystemUri" -Headers $spiderHeader -Method PUT -ContentType "application/json" -Body $SpiderRequestADD
IF(($Results.StatusCode -like "200")){Write-log -Message "$EntityID $Asset Asset unit ID was disabled successfully" -Country $Country -Severity Information}else{
Write-log -Message "$EntityID $Asset Asset Unit ID was not disabled" -Country $Country -Severity Error
}

Wait-Event -Timeout 5



}
}else{Write-log -Message "No outdated Asset Units info were found." -Country $Country -Severity Information}


$SpiderFunctionUnitList = Get-SpiderSwitches -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -Country $Country  -ReportNumber $ReportNumber
 
Wait-Event -Timeout 5

$CurrentAssetsInactive = ($SpiderFunctionUnitList | ? {$_."asset Status" -notlike "active"} |? {$_."asset number" -like "$AssetNumberReg"})  | Select -exp "asset number"

try{$AssetstoActivate = diff $CurrentAssetsInactive $Assets_Table.assetid  -IncludeEqual | ? {$_.SideIndicator -like "=="} | Select -exp InputObject}catch{}

if($AssetstoActivate){
Write-log -Message "Old in use device's Asset Units detected.Need to enable in Spider" -Country $Country -Severity Warning

Foreach($Asset in $AssetstoActivate){


$EntityID = $SpiderFunctionUnitList | ? {$_."asset number" -like $Asset} | Select -exp assetid | Select -Unique


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 

$spiderPair = "$($spiderUser):$($spiderPass)"
$spiderEncodedlogin = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($spiderPair))
$spiderAuthheader = "Basic " + $spiderEncodedlogin
$spiderTokenHeaders = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderTokenHeaders.Add("Authorization",$spiderAuthheader)
$spiderTokenHeaders.Add("Accept","application/json")
$spiderTokenHeaders.Add("Cache-Control","no-cache")


$spiderTokenUri = "$spiderApiBaseUri/token"
$spiderTokenResponse = Invoke-WebRequest -Uri $spiderTokenUri -Headers $spiderTokenHeaders -Method Get -ContentType "application/json"
$spiderAuthToken = $spiderTokenResponse.Headers.Token
$spiderTokenAuth = "Token " + $spiderAuthToken
$spiderHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$spiderHeader.Add("Authorization",$spiderTokenAuth)
$spiderHeader.Add("Accept","application/json")
$spiderHeader.Add("Cache-Control","no-cache")

$jsonBase = @{}
$listPara = @{"assetStatusID"=12;"hostName"="$($SpiderFunctionUnitList | ? {$_."asset number" -like $Asset} | Select -exp name | Select -Unique)";"inventoryImportView"="Solarwinds API";}
$jsonBase.Add('fields', $listPAra)
$SpiderRequestADD = $jsonBase | ConvertTo-Json
$SpiderSwitchSystemUri = "/0/entity/$($SpiderFunctionUnitList | ? {$_."asset number" -like $Asset}|Select -exp "asset Type")/$EntityID"

$Results = $null

$Results = Invoke-WebRequest -Uri "$spiderApiBaseUri$SpiderSwitchSystemUri" -Headers $spiderHeader -Method PUT -ContentType "application/json" -Body $SpiderRequestADD
IF(($Results.StatusCode -like "200")){Write-log -Message "$EntityID $Asset Asset unit ID was enabled successfully" -Country $Country -Severity Information}else{
Write-log -Message "$EntityID $Asset Asset Unit ID was not enabled" -Country $Country -Severity Error
}

Wait-Event -Timeout 5



}


}else{Write-log -Message "No outdated Asset Units info were found." -Country $Country -Severity Information}

}

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Country,

 
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Information','Warning','Error')]
        [string]$Severity = 'Information'
    )
 
    $scriptFolder = $MyInvocation.PSScriptRoot
    
    $Logged = (Get-Date -f g)+"|Message- "+$Message+"|Severity- "+$Severity

 If($Severity -like "Information"){write-host -ForegroundColor green $Logged}
 Elseif($Severity -like 'Warning'){write-host -ForegroundColor yellow $Logged}
 Elseif($Severity -like 'Error'){write-host -ForegroundColor red $Logged}

 try{$Logged  | Out-file -FilePath "$scriptFolder\Spider_Solarwinds_Sync_$($Country)_$(Get-date -f dd_MM_yyyy).txt" -Append }catch{write-host -ForegroundColor red "Check your access to script file location"}
 }


_Main_ -spiderUser $spiderUser -spiderPass $spiderPass -spiderApiBaseUri $spiderApiBaseUri -SQLDatabase $SQLDatabase -SQLServerInstance $SQLServerInstance -SQLUsername $SQLUsername -SQLPassword $SQLPassword -Country $Country -ReportNumber $ReportNumber -AssetNumberReg $AssetNumberReg