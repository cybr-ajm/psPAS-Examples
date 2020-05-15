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
$CSVPath = ".\rootimport.csv"
$CSVFile = import-csv -Path $CSVPath

#define a Cyberark User with access to add accounts to the target safe, Administrator in this case
$apiCred = Get-Credential Administrator

#PVWA Address without /PasswordVault
$PVWA_Address = "https://mypvwa"


######BEGIN PROVISIONING######

#Connect to API
New-PASSession -Credential $apiCred -BaseURI $PVWA_Address

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

    #Log output to screen, add accounts
    Write-Host "Adding account for $userName on $hostname to safe $safe with platform $platform"
    Add-PASAccount -userName $userName -password (ConvertTo-SecureString -string $currentPass -AsPlainText -Force) -SafeName $safe -platformID $platform -address $hostname -ExtraPass1Name $logonAccount -ExtraPass1Safe $logonSafe -ExtraPass1Folder $logonFolder -Verbose -Debug
}

Close-PASSession