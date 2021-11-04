$PVWA = 'https://comp01.cybr.com'
$appID = 'TestApp1'
$apiCred = Get-Credential Administrator
$inputFile = import-csv C:\users\john\Desktop\ips.csv

Import-Module psPAS
New-PASSession -BaseURI $PVWA -concurrentSession $true -Credential $apiCred

foreach($record in $inputFile){
    $address = $record.ip
    Add-PASApplicationAuthenticationMethod -AppID $appID -machineAddress $address -Verbose
}


Get-PASApplicationAuthenticationMethod -AppID $appID -Verbose -Debug
Close-PASSession

