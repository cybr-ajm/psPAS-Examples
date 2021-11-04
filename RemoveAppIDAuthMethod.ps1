$PVWA = 'https://comp01.cybr.com'
$appID = 'TestApp1'
$apiCred = Get-Credential Administrator

Import-Module psPAS
New-PASSession -BaseURI $PVWA -concurrentSession $true -Credential $apiCred

Get-PASApplicationAuthenticationMethod -AppID $appID -Verbose -Debug

Get-PASApplicationAuthenticationMethod -AppID $appID | Remove-PASApplicationAuthenticationMethod -Verbose -Debug

Get-PASApplicationAuthenticationMethod -AppID $appID -Verbose -Debug


Close-PASSession

