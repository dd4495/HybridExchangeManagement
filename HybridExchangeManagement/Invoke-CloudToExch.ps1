Function Invoke-CloudToExch {
    <#
            .SYNOPSIS
            Migrates a mailbox from O365 to On-prem.
            .DESCRIPTION
            This function prepares a mailbox for migration, starts dirsync, then finishes the migration automatically.
            To run this command, you must first connect to the O365 and On-prem email environments.
            .PARAMETER username
            The username of the individual whose mailbox you're migrating
            .PARAMETER GUID
            The O365 GUID of the individual whose mailbox you're migrating
            .PARAMETER Database
            The number of the on-prem destination database 
            .PARAMETER RemoteHost
            Your on-prem email domain
            .PARAMETER DSServer
            The FQDN of your DirSync Server
            .PARAMETER DeliveryDomain
            Your default email suffix
            .PARAMETER RemoteDomain
            Your O365 mail domain
            .PARAMETER O365User
            O365 admin user
            You can change the default, or you can enter it every time
            .PARAMETER O365Pass
            O365 admin password
            You can change the default, or you can enter it every time
            .PARAMETER ExchUser
            On-prem admin user
            You can change the default, or you can enter it every time
            .PARAMETER ExchPass
            On-prem admin password
            You can change the default, or you can enter it every time
            .PARAMETER BadItemLimit
            The maximum number of corrupted items to allow before a migration fails
            Only set this value if a migration fails due to too many corrupted items
            The default value of this parameter is 25
            .PARAMETER LargeItemLimit
            The maximum number of large items to allow before a migration fails
            Only set this value if a migration fails due to too many large items
            The default value of this parameter is 25
            .EXAMPLE
            Invoke-CloudToExch -Username meowth -GUID "0x000x00-y0yy-000y-0000-00000z0z00zz" -Database 01 -RemoteHost mail.domain.com -DSServer dirsyncsrv.domain.com -DeliveryDomain domain.com -RemoteDomain o365Domain.domain.com
    #>
    [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'Low')]
    param 
    (
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 0,HelpMessage = 'Please enter a username')]
        [string]$username,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 1,HelpMessage = 'Enter a GUID')]
        [string]$GUID,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 2,HelpMessage = 'Enter a database')]
        [string]$Database,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 3,HelpMessage = 'Enter the remote host name')]
        [string]$RemoteHost,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 4,HelpMessage = 'Enter the FQDN of your DirSync Server')]
        [string]$DSServer,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 5,HelpMessage = 'Enter your default email suffix')]
        [string]$DeliveryDomain,
        [Parameter(Mandatory = $True,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 6,HelpMessage = 'Enter your On-prem email domain')]
        [string]$RemoteDomain,
        [Parameter(Mandatory = $False,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 7,HelpMessage = 'Please enter a username')]
        [string]$O365User='admin@domain.onmicrosoft.com',
        [Parameter(Mandatory = $False,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 8,HelpMessage = 'Please enter a password')]
        [string]$O365Pass='P@ssword',
        [Parameter(Mandatory = $False,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 9,HelpMessage = 'Please enter a username')]
        [string]$ExchUser='domain\admin',
        [Parameter(Mandatory = $False,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 10,HelpMessage = 'Please enter a password')]
        [string]$ExchPass='P@ssword!',
        [Parameter(Mandatory = $False,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 11,HelpMessage = 'Enter a bad item limit')]
        [string]$BadItemLimit = '25',
        [Parameter(Mandatory = $False,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True,Position = 12,HelpMessage = 'Enter a large item limit')]
        [string]$LargeItemLimit = '25',
        [parameter()][Switch] $AsJob
    )
    #region setup
    $EmailAddress = [string]::Concat($($username),"@$RemoteDomain")   
    Enable-ERemotemailbox $username -remoteroutingaddress $EmailAddress
    Set-ERemotemailbox $username -ExchangeGUID $GUID
    #endregion
    #region Dirsync
    try{Get-MsolAccountSku -ErrorAction Stop }
    catch [Microsoft.Online.Administration.Automation.MicrosoftOnlineException]
    {'Not connected to MSOnline. Script is now connecting.'
        $O365pw = ConvertTo-SecureString -AsPlainText -Force -String $O365Pass
        $O365Cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $O365User, $O365pw
        Connect-MsolService -Credential $O365Cred
    }

    $DirSyncTimeBefore = Get-MsolCompanyInformation | Select-Object LastDirSyncTime
    $dstimeb = $DirSyncTimeBefore.LastDirSyncTime

    $ScriptBlock = {
        Invoke-Command -ComputerName "$DSServer" {"$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" ` 
            -psconsolefile "$env:ProgramFiles\Windows Azure Active Directory Sync\DirSyncConfigShell.psc1" ` 
        -command 'Start-OnlineCoexistenceSync'}
    }
    if ($AsJob){
        Start-Job -ScriptBlock $ScriptBlock
    } 
    else {
        Invoke-Command -ScriptBlock $ScriptBlock
    }
    while ($timetest  -ne $True){
        $DirsyncTimeNow = Get-MsolCompanyInformation | Select-Object LastDirSyncTime
        $dstimen = $DirsyncTimeNow.LastDirSyncTime
        $timetest = $DirsyncTimeNow.LastDirSyncTime –gt $DirSyncTimeBefore.LastDirSyncTime
        Start-Sleep(20) #sleep for 20 seconds
    }
    #endregion
    #region mailboxMove
    $ExPW = ConvertTo-SecureString -AsPlainText -Force -String $ExchPass
    $ExCred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ExchPass, $ExPW
    New-OMoveRequest -Outbound -RemoteTargetDatabase "DB$Database" -RemoteHostName $RemoteHost -RemoteCredential $ExCred -TargetDeliveryDomain $DeliveryDomain -Identity $username@$RemoteDomain -BadItemLimit 25

    $status = ((Get-OMoveRequest).where{$_.alias -eq $username}).status
    while ($status -ne 'AllDone'){
        if ($status -eq 'InProgress') {
            #Write-Output "$status"
            Start-Sleep -Seconds 15
        }
        elseif ($status -eq 'Failed') {
            $status = 'AllDone'
        }
        elseif ($status = 'Completed') {
            $status = 'AllDone'
        }
        else {$status = 'AllDone'}
    }
    #endregion
}