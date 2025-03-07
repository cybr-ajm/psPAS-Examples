Param(
    [Parameter()]
    [string]$pvwaURI = 'YOUR PVWA ADDRESS HERE',

    [Parameter()]
    [string]$idpURL = "YOUR IDP SSO URL HERE",
    
    [Parameter(ValueFromPipeline=$true)]
    [string]$targetHost,

    [Parameter(ValueFromPipeline=$true)]
    [string]$targetUser = "PRIV ACCOUNT TO RETRIEVE FROM VAULT",

    [Parameter(ValueFromPipeline=$true)]
    [string]$targetSafe = 'TARGETSAFENAME',

    [Parameter()]
    [string]$apiUser = 'USERNAME TO QUERY API',

    [Parameter()]
    [string]$OU = 'AD OU TO SEARCH',

    [Parameter()]
    [string]$localServiceAccountUserName = 'svc_ansible',

    [Parameter()]
    [string]$localServiceAccountPassword = "",

    [Parameter()]
    [string]$localServiceAccountDescription = 'Service Account for Ansible',

    [Parameter()]
    [string]$localServiceAccountGroup = 'Administrators',

    [Parameter()]
    [string]$localServiceAccountSafe = "AnsibleSafe",

    [Parameter()]
    [string]$localServiceAccountPlatformID = "WinServerLocal"
)

Import-Module psPAS -RequiredVersion 6.4.85
Import-Module ActiveDirectory

function Generate-RandomString {
    param(
        [int]$Length = 12,
        [string]$CharacterSets = "ALPHANUMERIC"
    )

    $alphaLower = "abcdefghijklmnopqrstuvwxyz"
    $alphaUpper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    $numeric = "0123456789"
    $special = "!@#$%^&*()_+-=[]{}|;':\,./<>?"

    $characters = ""

    if ($CharacterSets -match "ALPHANUMERIC") {
        $characters += $alphaLower + $alphaUpper + $numeric
    }
    if ($CharacterSets -match "ALPHA") {
         $characters += $alphaLower + $alphaUpper
    }
    if ($CharacterSets -match "NUMERIC") {
        $characters += $numeric
    }
    if ($CharacterSets -match "SPECIAL") {
        $characters += $special
    }

    $randomString = ""
    for ($i = 0; $i -lt $Length; $i++) {
        $randomIndex = Get-Random -Maximum $characters.Length
        $randomString += $characters[$randomIndex]
    }
    return $randomString
}

#Perform human auth using IdP login
$loginResponse = New-SAMLInteractive -LoginIDP $idpURL

#Establish new API session to CyberArk
New-PASSession -BaseURI $pvwaURI -SAMLAuth -SAMLResponse $loginResponse

#Retrive the privileged domain user to use for local account provisioning
$privAccountPwd = (Get-PASAccount -safeName $targetSafe -search $targetUser | Get-PASAccountPassword).Password | ConvertTo-SecureString -AsPlainText -Force

#Use the retrieved username/password to make a PS Credential object we can use to connect to the target systems
$privAccountCredObj = New-Object System.Management.Automation.PSCredential ($targetUser, $privAccountPwd)

#Query AD OU for computer accounts
$ComputerList = Get-ADComputer -Credential $privAccountCredObj -SearchBase $OU -Filter *

foreach($computer in $ComputerList){
    #generate new random initial password
    $localServiceAccountPassword = ConvertTo-SecureString (Generate-RandomString -Length 20 -CharacterSets "ALPHANUMERIC,SPECIAL") -AsPlainText

    Invoke-Command -ComputerName $computer.DNSHostname -Credential $privAccountCredObj -ScriptBlock {
        #Create new user and add them to defined group
        New-LocalUser -Name $using:localServiceAccountUserName -Password $using:localServiceAccountPassword -Description $using:localServiceAccountDescription
        Add-LocalGroupMember -Group $using:localServiceAccountGroup -Member $using:localServiceAccountUserName
    }
    
    #Add the account to the vault and schedule for immediate change
    Add-PASAccount -userName $localServiceAccountUserName -address $computer.DNSHostname -SafeName $localServiceAccountSafe -platformID $localServiceAccountPlatformID -secret $localServiceAccountPassword | Invoke-PASCPMOperation -ChangeTask

}

#Log off from API
#Close-PASSession
