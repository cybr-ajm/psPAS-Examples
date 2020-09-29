<#
.SYNOPSIS
Takes a CSV file as input (see sample rootimport.csv)
Creates the account in PAS Vault, with logon account attached.
#>

#Installs psPAS module from Powershell Gallery
Install-Module psPAS

#Imports the psPAS module
Import-Module psPAS


###DEFINE VARIABLES###

#Import CSV File
$CSVPath = "C:\rootimport.csv"
$CSVFile = import-csv -Path $CSVPath

#define a Cyberark User with access to add accounts to the target safe, Administrator in this case
$apiCred = Get-Credential Administrator

#PVWA Address without /PasswordVault
$PVWA_Address = "https://myPVWA"

#LDAP Integration Domain
$searchDomain = 'myDomain.com'


#####BEGIN PROVISIONING#####

#Connect to API
New-PASSession -Credential $apiCred -BaseURI $PVWA_Address



#####DEFINE SAFE ROLES#####

#Normal user role, can use/retrieve privileged accounts
$safeUserRole = [PSCustomObject]@{
  UseAccounts                            = $true
  ListAccounts                           = $true
  RetrieveAccounts						 = $true
  ViewAuditLog                           = $true
  ViewSafeMembers                        = $true
}

#Safe manager role, can add additional accounts, initiate CPM ops
$safeManagerRole = [PSCustomObject]@{
  UseAccounts                            = $true
  ListAccounts                           = $true
  RetrieveAccounts						 = $true
  ViewAuditLog                           = $true
  ViewSafeMembers                        = $true
  AddAccounts = $true
  UpdateAccountContent = $true
  InitiateCPMAccountManagementOperations = $true
}

foreach($record in $CSVFile){
    
    #Get values needed from current row
    $hostname = $record.Hostname
    $userName = $record.AccountName
    $currentPass = $record.CurrentPasswd
    $platform = $record.Platform
    $safe = $record.Safe
    $logonAccount = $record.LogonAccount
    $logonSafe = "Linux Accounts"
    $logonFolder = "Root"

    #Queries for the safe name
    $existingSafe = Get-PASSafe -SafeName $safe

    #If the safe exists, skip creation. Otherwise, create the safe and assign the two role groups as members.
    if($existingSafe){
        Write-Host "Safe $safe exists, skipping safe creation"
    }else{
        Write-Host "Safe $safe does not exist, creating safe"
        Add-PASSafe -SafeName $safe -Description "Safe for storing $safe accounts" -ManagingCPM 'PasswordManager' -NumberOfDaysRetention '3'
        $safeUserRole | Add-PASSafeMember -SafeName $safe -MemberName "$safe Safe Users" -SearchIn $searchDomain
        $safeManagerRole | Add-PASSafeMember -SafeName $safe -MemberName "$safe Safe Managers" -SearchIn $searchDomain
    }


    #Log output to screen, add account
    Write-Host "Adding account for $userName on $hostname to safe $safe with platform $platform"
    Add-PASAccount -userName $userName -password (ConvertTo-SecureString -string $currentPass -AsPlainText -Force) -SafeName $safe -platformID $platform -address $hostname -ExtraPass1Name $logonAccount -ExtraPass1Safe $logonSafe -ExtraPass1Folder $logonFolder -Verbose -Debug
}

Close-PASSession
