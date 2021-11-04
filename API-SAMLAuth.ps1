Import-Module psPAS
Import-Module PS-SAML-Interactive
#Instantiate variables
$PVWA = 'https://comp01.cybr.com'
$IdPURL = 'https://aac4146.my.idaptive.app/applogin/appKey/b21ed38b-4219-4a48-be98-756d84779248/customerId/AAC4146'

#Initiate REST API session
$loginResponse = New-SAMLInteractive -LoginIDP $IdPURL
$loginResponse
New-PASSession -BaseURI $PVWA -concurrentSession $true -SAMLAuth -SAMLResponse $loginResponse

#Test query
Get-PASAccount -Keywords John_Admin -Verbose -Debug
Get-PASSafe -SafeName John_Admin -Verbose -Debug
Get-PASPlatformSummary
#Close REST API session
Close-PASSession