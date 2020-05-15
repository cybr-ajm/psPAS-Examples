
$adminCreds = Get-Credential Administrator
$vaultIP = "10.0.0.10"
$vaultName = "DemoVault"

Import-Module PoShPACLI

Start-PVPacli

New-PVVaultDefinition -vault $vaultName -address $vaultIP

Connect-PVVault -user $($adminCreds.UserName) -password $($adminCreds.Password)

#$userList = Get-PVUserList  | Where-Object{$_.LDAPUser -eq "YES" -and $_.Type -eq "EXTERNAL USER"}
$userList = Get-PVUserList  | Where-Object{$_.LDAPUser -eq "NO" -and $_.Type -eq "USER"  -and  ($_.Username -like "e0*" -or $_.Username -like "n9*")}
#$userList = Import-Csv C:\temp\export.csv -Header Username

foreach($user in $userList){
    $name = $user.Username
    $type = $user.Type

    Write-Host "$name"

   Set-PVUser -destUser $name -authType LDAP_AUTH
}

Disconnect-PVVault

Stop-PVPacli