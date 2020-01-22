$apiCred = Get-Credential
$apiURL = 'https://'

New-PASSession -Credential $apiCred -BaseURI $apiURL -Verbose -type LDAP

$addOrRemove = Read-Host "Would you like to (A)dd or (R)emove a PAS Account?"

if($addOrRemove -eq 'A' -or $addOrRemove -eq 'a'){
    Write-Host 'Add a PAS account selected' -ForegroundColor Green
    $accountUsername = Read-Host "Enter the account username"
    $accountAddress = Read-Host "Enter the account address"
    $accountPlatform = Read-Host "Enter the account platform"
    $accountSafe = Read-Host "Enter the safe name to onboard the account"
    $accountFriendlyName = Read-Host "Enter the display (object) name for the account"

    Add-PASAccount -Verbose -userName $accountUsername -platformID $accountPlatform -address $accountAddress -SafeName $accountSafe

    } elseif ($addOrRemove -eq 'R' -or $addOrRemove -eq 'r'){
    Write-Host 'Remove a PAS account selected' -ForegroundColor Green
    $accountObjectName = (Read-Host "Enter the object name to delete:").ToString()

    Get-PASAccount -Verbose -search $accountObjectName | Remove-PASAccount -Verbose

    } else {
    Write-Host 'Invalid Option Selected' -ForegroundColor Red
    }

Close-PASSession -Verbose