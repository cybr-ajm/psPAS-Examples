$iterations = 500
$PVWA = 'https://comp01.cybr.com'
$appID = 'TestApp1'
$ipPrefix = '192.168.1.'
$apiCred = Get-Credential Administrator

Import-Module psPAS
New-PASSession -BaseURI $PVWA -concurrentSession $true -Credential $apiCred

for($lcv=1;$lcv -lt $iterations;$lcv++){
    $address = "$ipPrefix$lcv"
    Add-PASApplicationAuthenticationMethod -AppID $appID -machineAddress $address -Verbose
}


Get-PASApplicationAuthenticationMethod -AppID $appID -Verbose -Debug
Close-PASSession