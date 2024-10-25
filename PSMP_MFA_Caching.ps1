Import-Module psPAS -RequiredVersion 5.4.101
Import-Module PS-SAML-Interactive

$connString = $args[0]

#Instantiate variables
$PVWA = 'https://comp01.cybr.com'
$IdPURL = 'https://aac4146.my.idaptive.app/applogin/appKey/b21ed38b-4219-4a48-be98-756d84779248/customerId/AAC4146'
$myKeyPath = 'C:\users\john\.ssh\myKey.pem'
$sshClient = "ssh"

$logonUser, $targetUser, $targetHost, $psmp = $connString -split "@"

#Initiate REST API session
Write-Output "Launching SAML Authentication"
$loginResponse = New-SAMLInteractive -LoginIDP $IdPURL
#echo $loginResponse
Write-Output "Authenticating to PVWA API"
New-PASSession -BaseURI $PVWA -concurrentSession $true -SAMLAuth -SAMLResponse $loginResponse -SkipCertificateCheck
#Retrieve ssh key and start session to PSMP
Write-Output "Retrieving SSH Key"
$myKey = New-PASPrivateSSHKey -formats OpenSSH
Write-Output "Saving Private Key"
$myKey.value.privateKey | Out-File $myKeyPath -Encoding ascii

#Close REST API session
Write-Output "Closing API Session"
Close-PASSession

#Open SSH connection to target
Write-Output "Launching PSMP session to target"
&$sshClient -i $myKeyPath $logonUser@$targetUser@$targetHost@$psmp