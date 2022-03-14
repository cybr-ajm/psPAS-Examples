Import-Module psPAS
Import-Module PS-SAML-Interactive

#Instantiate variables
$PVWA = 'https://<PVWA URL - /PasswordVault is not necessary>'
$IdPURL = '<SSO URL HERE>'
$myKeyPath = '<LOCATION TO DOWNLOAD SSH KEY>'
$sshClient = "C:\Program Files\PuTTY\putty.exe"
$vaultUser = '<VAULT USER NAME>'
$targetUser = 'root'
$targetServer = '<FQDN OR IP OF TARGET HOST>'
$psmpAddress = '<PSMP SERVER ADDRESS>'

#Initiate REST API session
Write-Output "Launching SAML Authentication"
$loginResponse = New-SAMLInteractive -LoginIDP $IdPURL

Write-Output "Authenticating to PVWA API"
New-PASSession -BaseURI $PVWA -concurrentSession $true -SAMLAuth -SAMLResponse $loginResponse

#Retrieve ssh key and start session to PSMP
Write-Output "Retrieving SSH Key"
$myKey = New-PASPrivateSSHKey -formats PPK
Write-Output "Saving Private Key"
$myKey.value.privateKey | Out-File $myKeyPath -Encoding ascii

#Close REST API session
Write-Output "Closing API Session"
Close-PASSession

#Open SSH connection to target
Write-Output "Launching PSMP session to target"
&$sshClient -ssh -i $myKeyPath $vaultUser@$targetUser@$targetServer@$psmpAddress