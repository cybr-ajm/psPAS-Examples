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
$CSVPath = "C:\safeimport.csv"
$CSVFile = import-csv -Path $CSVPath

#define a Cyberark User with access to add accounts to the target safe, Administrator in this case
$apiCred = Get-Credential Administrator

#PVWA Address without /PasswordVault
$PVWA_Address = "https://<pvwa_address>"

#LDAP Integration Domain
$searchDomain = '<domain where groups are>'


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
    $safe = $record.SafeName
    $safeDesc = $record.Description
    $retentionDays = $record.RetentionDays
    $CPM = $record.CPM
    $usersGroup = $record.SafeUsersGroup
    $managersGroup = $record.SafeManagersGroup


    #Queries for the safe name
    $existingSafe = Get-PASSafe -SafeName $safe

    #If the safe exists, skip creation. Otherwise, create the safe and assign the two role groups as members.
    if($existingSafe){
    
        Write-Host "Safe $safe exists, skipping safe creation"

         if($usersGroup){
            Write-Host "Adding $usersGroup as Safe Users"
            $safeUserRole | Add-PASSafeMember -SafeName $safe -MemberName "$usersGroup" -SearchIn $searchDomain
        }
         
        if($managersGroup){
            Write-Host "Adding $managersGroup as Safe Managers"
            $safeManagerRole | Add-PASSafeMember -SafeName $safe -MemberName "$managersGroup" -SearchIn $searchDomain
        } 

    }else{

        Write-Host "Safe $safe does not exist, creating safe"
        Add-PASSafe -SafeName $safe -Description $safeDesc -ManagingCPM $CPM -NumberOfDaysRetention $retentionDays

        if($usersGroup){
            Write-Host "Adding $usersGroup as Safe Users"
            $safeUserRole | Add-PASSafeMember -SafeName $safe -MemberName "$usersGroup" -SearchIn $searchDomain
        }
         
        if($managersGroup){
            Write-Host "Adding $managersGroup as Safe Managers"
            $safeManagerRole | Add-PASSafeMember -SafeName $safe -MemberName "$managersGroup" -SearchIn $searchDomain
        }           
    }
}

Close-PASSession
