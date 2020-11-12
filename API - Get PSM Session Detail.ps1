#Install pre-reqs
install-module psPAS
import-module psPAS

#Instantiate variables
$PVWA = 'https://pvwa.example.com'
$cred = Get-Credential Administrator
$array = @()

#Initiate REST API session
New-PASSession -BaseURI $PVWA -Credential $cred

#Get recordings - optionally add searches and/or filter parameters
$PSMRecordings = Get-PASPSMRecording

#Loop through each recording record
foreach($sessionRecording in $PSMRecordings){
#Get the recording detail for current recording
$recordingProperties = $sessionRecording | Get-PASPSMRecordingProperty
$PSMProviderID =''
    
    #Find the PSM provider ID in the Raw Properties returned
    if ($recordingProperties.RawProperties -match '(ProviderID=)(\w*)'){
        $PSMProviderID = $Matches.2
    }
    
    #Look up the PSM server by its provider ID
    $PSMServerInfo = Get-PASComponentDetail -ComponentID SessionManagement | Where-Object {$_.ComponentUserName -eq $PSMProviderID}

    #create a custom PS object with the desired properties
    $obj = new-object psobject -Property @{
                   SessionGUID = $recordingProperties.SessionGuid
                   CyberArkUser = $recordingProperties.User
                   PrivilegedAccount = $recordingProperties.AccountUsername
                   TargetServer = $recordingProperties.RemoteMachine
                   ConnectionComponent = $recordingProperties.ConnectionComponentID
                   PSMServerIP = $PSMServerInfo.ComponentIP
                   TimestampStart =(Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($recordingProperties.Start)) 
                   TimestampEnd = (Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($recordingProperties.End)) 
               }
    #add the custom object to our array
    $array += $obj
}

#Output the array in a table format
$array | ft

#Close out the REST API Session
Close-PASSession
